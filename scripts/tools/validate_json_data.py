#!/usr/bin/env python3
"""Validate gameplay JSON rows against DataManager schema checks.

This mirrors the validation rules in scripts/managers/data_manager.gd and
adds explicit error reasons per row.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[2]
JSON_DIR = ROOT / "data" / "json"


def _is_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def _expect_keys(row: dict[str, Any], required: list[str]) -> list[str]:
    return [k for k in required if k not in row]


def _validate_stat_block(value: Any) -> str | None:
    if not isinstance(value, dict):
        return "stat block must be an object"

    required = ["STR", "INT", "DEX", "VIT"]
    missing = _expect_keys(value, required)
    if missing:
        return f"missing stat keys: {missing}"

    wrong_types = [k for k in required if not _is_int(value[k])]
    if wrong_types:
        return f"stat values must be int for keys: {wrong_types}"

    return None


def _validate_enemy(row: dict[str, Any]) -> str | None:
    required = ["id", "name", "rank", "base_stats", "skills", "passive_effects", "ai_pattern", "reward"]
    missing = _expect_keys(row, required)
    if missing:
        return f"missing keys: {missing}"

    if not isinstance(row["id"], str):
        return "id must be string"
    if not isinstance(row["name"], str):
        return "name must be string"
    if not _is_int(row["rank"]):
        return "rank must be int"

    reason = _validate_stat_block(row["base_stats"])
    if reason:
        return f"base_stats invalid: {reason}"

    if not isinstance(row["skills"], list):
        return "skills must be array"
    if not isinstance(row["passive_effects"], list):
        return "passive_effects must be array"
    if not isinstance(row["ai_pattern"], list):
        return "ai_pattern must be array"

    reward = row["reward"]
    if not isinstance(reward, dict):
        return "reward must be object"

    missing = _expect_keys(reward, ["gold", "exp"])
    if missing:
        return f"reward missing keys: {missing}"
    if not _is_int(reward["gold"]):
        return "reward.gold must be int"
    if not _is_int(reward["exp"]):
        return "reward.exp must be int"

    return None


def _validate_passive(row: dict[str, Any]) -> str | None:
    required = ["id", "name", "rarity", "max_level", "stat_bonus", "active_effect", "description"]
    missing = _expect_keys(row, required)
    if missing:
        return f"missing keys: {missing}"

    if not isinstance(row["id"], str):
        return "id must be string"
    if not isinstance(row["name"], str):
        return "name must be string"
    if not isinstance(row["rarity"], str):
        return "rarity must be string"
    if not _is_int(row["max_level"]):
        return "max_level must be int"

    reason = _validate_stat_block(row["stat_bonus"])
    if reason:
        return f"stat_bonus invalid: {reason}"

    if not isinstance(row["active_effect"], str):
        return "active_effect must be string"
    if not isinstance(row["description"], str):
        return "description must be string"

    return None


def _validate_skill(row: dict[str, Any]) -> str | None:
    required = ["id", "name", "type", "resource_cost", "status_effect", "effect_value", "description"]
    missing = _expect_keys(row, required)
    if missing:
        return f"missing keys: {missing}"

    if not isinstance(row["id"], str):
        return "id must be string"
    if not isinstance(row["name"], str):
        return "name must be string"
    if not isinstance(row["type"], str):
        return "type must be string"
    if not _is_int(row["effect_value"]):
        return "effect_value must be int"

    resource = row["resource_cost"]
    if not isinstance(resource, dict):
        return "resource_cost must be object"
    missing = _expect_keys(resource, ["mp", "ki"])
    if missing:
        return f"resource_cost missing keys: {missing}"
    if not _is_int(resource["mp"]):
        return "resource_cost.mp must be int"
    if not _is_int(resource["ki"]):
        return "resource_cost.ki must be int"

    if not isinstance(row["status_effect"], str):
        return "status_effect must be string"
    if not isinstance(row["description"], str):
        return "description must be string"

    return None


def _validate_quest(row: dict[str, Any]) -> str | None:
    required = ["id", "name", "type", "objectives", "time_limit", "rewards", "branching_flags"]
    missing = _expect_keys(row, required)
    if missing:
        return f"missing keys: {missing}"

    if not isinstance(row["id"], str):
        return "id must be string"
    if not isinstance(row["name"], str):
        return "name must be string"
    if not isinstance(row["type"], str):
        return "type must be string"
    if not _is_int(row["time_limit"]):
        return "time_limit must be int"
    if not isinstance(row["objectives"], list):
        return "objectives must be array"
    if not isinstance(row["rewards"], dict):
        return "rewards must be object"
    if not isinstance(row["branching_flags"], list):
        return "branching_flags must be array"

    return None


def _validate_file(file_name: str, list_key: str, validator: Callable[[dict[str, Any]], str | None]) -> list[str]:
    path = JSON_DIR / file_name
    with path.open("r", encoding="utf-8") as f:
        root = json.load(f)

    errors: list[str] = []
    rows = root.get(list_key)
    if not isinstance(rows, list):
        return [f"[{file_name}] '{list_key}' must be an array"]

    seen: set[str] = set()
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            errors.append(f"[{file_name}] row {index}: row must be object, got {type(row).__name__}")
            continue

        row_id = row.get("id", f"<missing-id:{index}>")
        if row_id in seen:
            errors.append(f"[{file_name}] row {index} id={row_id}: duplicate id")
        seen.add(str(row_id))

        reason = validator(row)
        if reason:
            errors.append(f"[{file_name}] row {index} id={row_id}: {reason}; row={json.dumps(row, ensure_ascii=False)}")

    return errors


def main() -> int:
    targets = [
        ("Skill.json", "skills", _validate_skill),
        ("EnemyStat.json", "enemies", _validate_enemy),
        ("Passive.json", "passives", _validate_passive),
        ("Quest.json", "quests", _validate_quest),
    ]

    all_errors: list[str] = []
    for file_name, list_key, validator in targets:
        all_errors.extend(_validate_file(file_name, list_key, validator))

    if all_errors:
        print("JSON validation FAILED")
        for err in all_errors:
            print(f"- {err}")
        return 1

    print("JSON validation PASSED: all rows satisfy DataManager schema checks.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
