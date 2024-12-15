#!/usr/bin/env python3

import subprocess
import csv
import argparse
import os
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def get_commit_details(origin_branch, target_branch):
    """Fetch commit details between two branches."""
    try:
        # Run the git command to get the log details
        result = subprocess.run(
            [
                "git",
                "log",
                "--oneline",
                f"{target_branch}..{origin_branch}",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True,
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error while fetching git log: {e.stderr}")
        exit(1)


def parse_commits(log_output):
    """Parse git log output into a structured list."""
    commits = {"hashes": [], "messages": []}

    for line in log_output.splitlines():
        commits["hashes"].append(line.split(" ")[0])
        commits["messages"].append(" ".join(line.split(" ")[1:]))

    return commits


def write_to_csv(commits, output_file: Path = PROJECT_ROOT / "changelog.csv"):
    """Write commit details to a CSV file."""
    with open(
        str(PROJECT_ROOT / output_file), mode="w", newline="", encoding="utf-8"
    ) as csvfile:
        fieldnames = ["Messages"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        writer.writeheader()
        for commit in commits:
            writer.writerow(
                {
                    "Messages": commit,
                }
            )


def main(args):
    # Ensure we're in a git repository
    if not os.path.exists(".git"):
        print("Error: This script must be run from the root of a Git repository.")
        exit(1)

    # Get the commit details
    log_output = get_commit_details(args.origin_branch, args.target_branch)
    print(log_output)

    # Parse the log output
    commits = parse_commits(log_output)
    print(commits)

    # Write the results to a CSV file
    write_to_csv(commits)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Extract commit details between two Git branches and output to a CSV file."
    )
    parser.add_argument(
        "-o", "--origin_branch", help="The origin branch to compare from."
    )
    parser.add_argument(
        "target_branch",
        help="The target branch to compare to.",
        action="store_const",
        const="main",
        default="",
    )
    args = parser.parse_args()

    main(args)
