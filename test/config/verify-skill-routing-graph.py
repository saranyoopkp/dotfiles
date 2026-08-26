#!/usr/bin/env python3
"""Verify that the Mermaid routing graph is linked to the current skill registry."""

from __future__ import annotations

import argparse
import re
import sys
import tempfile
from pathlib import Path


NODE_RE = re.compile(r'\b([A-Z][A-Z0-9_]*)\["([^"]+)"\]')
SUBGRAPH_RE = re.compile(r'^\s*subgraph\s+([A-Z][A-Z0-9_]*)\[')
EDGE_RE = re.compile(
    r'^\s*([A-Z][A-Z0-9_]*)\s+(-->|-\.->)\|([^|]+)\|\s+([A-Z][A-Z0-9_]*)'
)
LINK_RE = re.compile(r'\[[^\]]*\]\(([^)#\s]+)(?:#[^)]*)?\)')
NON_SKILL_NODE_IDS = {
    "REQ",
    "SCC",
    "ACV",
    "DELIVERY",
    "REWORK",
    "RISK_AUTH",
    "RISK_MONEY",
    "RISK_EXTERNAL",
    "RISK_PRODUCTION",
}


def frontmatter_name(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("missing opening frontmatter delimiter")
    try:
        end = next(i for i, line in enumerate(lines[1:], 1) if line.strip() == "---")
    except StopIteration as exc:
        raise ValueError("missing closing frontmatter delimiter") from exc
    for line in lines[1:end]:
        match = re.match(r"name:\s*['\"]?([^'\"]+?)['\"]?\s*$", line)
        if match:
            return match.group(1)
    raise ValueError("missing frontmatter name")


def discover_skills(skills_root: Path) -> tuple[dict[str, Path], list[tuple[str, str]]]:
    skills: dict[str, Path] = {}
    path_names: dict[Path, str] = {}
    errors: list[str] = []

    for manifest in sorted(skills_root.rglob("SKILL.md")):
        try:
            name = frontmatter_name(manifest)
        except ValueError as exc:
            errors.append(f"{manifest}: {exc}")
            continue
        if name in skills:
            errors.append(f"duplicate skill name {name!r}: {skills[name]} and {manifest}")
        skills[name] = manifest
        path_names[manifest] = name

    if errors:
        raise ValueError("\n".join(errors))

    parent_edges: list[tuple[str, str]] = []
    for manifest, child_name in path_names.items():
        relative = manifest.relative_to(skills_root)
        if len(relative.parts) != 3:
            continue
        parent_manifest = skills_root / relative.parts[0] / "SKILL.md"
        parent_name = path_names.get(parent_manifest)
        if parent_name is None:
            raise ValueError(f"nested skill {child_name!r} has no parent router: {parent_manifest}")
        parent_edges.append((parent_name, child_name))

    return skills, parent_edges


def parse_graph(
    graph_path: Path,
) -> tuple[dict[str, str], set[str], list[tuple[str, str, str, int]]]:
    nodes: dict[str, str] = {}
    subgraphs: set[str] = set()
    edges: list[tuple[str, str, str, int]] = []
    in_mermaid = False

    for line_number, line in enumerate(graph_path.read_text(encoding="utf-8").splitlines(), 1):
        if line.strip() == "```mermaid":
            in_mermaid = True
            continue
        if in_mermaid and line.strip() == "```":
            in_mermaid = False
            continue
        if not in_mermaid:
            continue
        subgraph = SUBGRAPH_RE.match(line)
        if subgraph:
            subgraphs.add(subgraph.group(1))
        for node_id, label in NODE_RE.findall(line):
            previous = nodes.get(node_id)
            if previous is not None and previous != label:
                raise ValueError(
                    f"graph node {node_id} has conflicting labels {previous!r} and {label!r}"
                )
            nodes[node_id] = label
        edge = EDGE_RE.match(line)
        if edge:
            source, _arrow, trigger, target = edge.groups()
            edges.append((source, target, trigger.strip(), line_number))

    if in_mermaid:
        raise ValueError("unclosed Mermaid fence")
    if not nodes or not edges:
        raise ValueError("Mermaid graph has no parsed nodes or edges")
    return nodes, subgraphs, edges


def markdown_without_code(text: str) -> str:
    """Remove fenced and inline code before interpreting Markdown links."""
    kept: list[str] = []
    in_fence = False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if not in_fence:
            kept.append(re.sub(r'`[^`]*`', '', line))
    return "\n".join(kept)


def validate_references(skills: dict[str, Path]) -> tuple[list[str], int]:
    findings: list[str] = []
    checked = 0
    for name, manifest in skills.items():
        text = markdown_without_code(manifest.read_text(encoding="utf-8"))
        for target in LINK_RE.findall(text):
            if target.startswith(("http://", "https://", "mailto:", "/", "#")):
                continue
            if any(marker in target for marker in ("<", ">", "{", "}", "*")):
                continue
            checked += 1
            resolved = (manifest.parent / target).resolve()
            if not resolved.exists():
                findings.append(f"skill {name!r} has missing relative reference: {target}")
    return findings, checked


def validate(root: Path, graph_path: Path) -> tuple[list[str], dict[str, int]]:
    skills_root = root / "claude" / "skills"
    skills, parent_edges = discover_skills(skills_root)
    nodes, subgraphs, graph_edges = parse_graph(graph_path)
    findings: list[str] = []

    edge_pairs = {(source, target) for source, target, _trigger, _line in graph_edges}
    label_ids: dict[str, list[str]] = {}
    for node_id, label in nodes.items():
        label_ids.setdefault(label, []).append(node_id)
        if node_id not in NON_SKILL_NODE_IDS and node_id not in subgraphs and label not in skills:
            findings.append(f"graph node {node_id} points to unknown skill: {label!r}")

    for name in sorted(skills):
        ids = label_ids.get(name, [])
        if not ids:
            findings.append(f"skill missing from graph: {name!r}")
        elif len(ids) > 1:
            findings.append(f"skill appears in multiple graph nodes: {name!r} -> {ids}")

    for source, target, trigger, line_number in graph_edges:
        if source not in nodes:
            findings.append(f"graph line {line_number}: edge source is undeclared: {source}")
        if target not in nodes:
            findings.append(f"graph line {line_number}: edge target is undeclared: {target}")
        if not trigger:
            findings.append(f"graph line {line_number}: edge has no trigger label")

    reachable = {"REQ"}
    while True:
        discovered = {
            target
            for source, target, _trigger, _line in graph_edges
            if source in reachable and target not in reachable
        }
        if not discovered:
            break
        reachable.update(discovered)
    for node_id in sorted(set(nodes) - subgraphs - reachable):
        findings.append(f"graph node is not reachable from REQ: {node_id}")

    child_names = {child for _parent, child in parent_edges}
    for parent_name, child_name in parent_edges:
        parent_id = label_ids.get(parent_name, [None])[0]
        child_id = label_ids.get(child_name, [None])[0]
        if parent_id and child_id and (parent_id, child_id) not in edge_pairs:
            findings.append(f"missing parent-child graph edge: {parent_name!r} -> {child_name!r}")
        parent_text = skills[parent_name].read_text(encoding="utf-8")
        if child_name not in parent_text:
            findings.append(f"parent router {parent_name!r} does not mention child {child_name!r}")

    for name in sorted(set(skills) - child_names):
        node_id = label_ids.get(name, [None])[0]
        if node_id and ("REQ", node_id) not in edge_pairs:
            findings.append(f"top-level skill is not reachable from REQ: {name!r}")

    reference_findings, references_checked = validate_references(skills)
    findings.extend(reference_findings)
    stats = {
        "skills": len(skills),
        "nodes": len(nodes),
        "edges": len(graph_edges),
        "parent_edges": len(parent_edges),
        "references": references_checked,
    }
    return findings, stats


def self_test(root: Path, graph_path: Path) -> None:
    """Prove that unlinking skill and acceptance routes produces findings."""
    skills, parent_edges = discover_skills(root / "claude" / "skills")
    nodes, _subgraphs, _edges = parse_graph(graph_path)
    node_by_label = {label: node_id for node_id, label in nodes.items()}
    parent_name, child_name = parent_edges[0]
    source = node_by_label[parent_name]
    target = node_by_label[child_name]

    graph_lines = graph_path.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(graph_lines):
        edge = EDGE_RE.match(line)
        if edge and edge.group(1) == source and edge.group(4) == target:
            indentation = line[: len(line) - len(line.lstrip())]
            graph_lines[index] = f'{indentation}{target}["{child_name}"]'
            break
    else:
        raise ValueError(f"self-test could not find edge {source} -> {target}")

    with tempfile.TemporaryDirectory(prefix="skill-routing-graph-") as temp_dir:
        broken_graph = Path(temp_dir) / "skill-routing-graph.md"
        broken_graph.write_text("\n".join(graph_lines) + "\n", encoding="utf-8")
        findings, _stats = validate(root, broken_graph)
    expected = f"missing parent-child graph edge: {parent_name!r} -> {child_name!r}"
    if expected not in findings:
        raise ValueError("self-test removed an edge but the validator did not report it")

    acceptance_lines = graph_path.read_text(encoding="utf-8").splitlines()
    for index, line in enumerate(acceptance_lines):
        edge = EDGE_RE.match(line)
        if edge and edge.group(1) == "SCC" and edge.group(4) == "ACV":
            del acceptance_lines[index]
            break
    else:
        raise ValueError("self-test could not find acceptance edge SCC -> ACV")

    with tempfile.TemporaryDirectory(prefix="acceptance-routing-graph-") as temp_dir:
        broken_graph = Path(temp_dir) / "skill-routing-graph.md"
        broken_graph.write_text("\n".join(acceptance_lines) + "\n", encoding="utf-8")
        findings, _stats = validate(root, broken_graph)
    if "graph node is not reachable from REQ: ACV" not in findings:
        raise ValueError("self-test unlinked ACV but the validator did not report it")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", type=Path, default=Path.cwd())
    parser.add_argument("--graph", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    graph = (args.graph or root / "docs" / "skill-routing-graph.md").resolve()

    try:
        findings, stats = validate(root, graph)
    except (OSError, ValueError) as exc:
        print(f"routing graph validation error: {exc}", file=sys.stderr)
        return 1

    if findings:
        for finding in findings:
            print(f"FAIL: {finding}", file=sys.stderr)
        print(f"routing graph validation failed: {len(findings)} finding(s)", file=sys.stderr)
        return 1

    if args.self_test:
        try:
            self_test(root, graph)
        except (OSError, ValueError) as exc:
            print(f"routing graph self-test failed: {exc}", file=sys.stderr)
            return 1

    print(
        "skill routing graph verified: "
        + " ".join(f"{key}={value}" for key, value in stats.items())
        + (" self_test=passed" if args.self_test else "")
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
