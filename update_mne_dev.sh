#!/bin/bash
# Updates all development repositories configured in paths.ini:
#   1. Fetches the newest version from the remotes
#   2. Merges the default branch of "upstream" (or "origin" if no upstream exists)
#      into the currently checked out branch
#   3. Renews the editable installation (pip install -e) in the activated environment

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read paths from paths.ini before initializing conda.
if [[ ! -f "$script_dir/paths.ini" ]]; then
    echo "ERROR: paths.ini not found beside this script."
    exit 1
fi
if ! source "$script_dir/paths.ini"; then
    echo "ERROR: Could not load paths.ini."
    exit 1
fi
echo "Package paths loaded from paths.ini"

target_env="${1:-}"
if [[ -n "$target_env" || -z "$CONDA_DEFAULT_ENV" || "$CONDA_DEFAULT_ENV" == "base" || -z "$CONDA_PREFIX" ]]; then
    if [[ -z "$target_env" ]]; then
        if ! read -r -p "Development environment name or full path [mnedev]: " target_env; then
            echo "ERROR: Cannot read an environment name. Run in a terminal or pass it as the first argument."
            exit 1
        fi
        target_env="${target_env:-mnedev}"
    fi
    if [[ -z "$conda_root" || ! -f "$conda_root/etc/profile.d/conda.sh" ]]; then
        echo "ERROR: Set conda_root in paths.ini to a conda installation containing etc/profile.d/conda.sh."
        exit 1
    fi
    if ! source "$conda_root/etc/profile.d/conda.sh"; then
        echo "ERROR: Could not initialize conda."
        exit 1
    fi
    if ! conda activate "$target_env"; then
        echo "ERROR: Could not activate conda environment '$target_env'."
        exit 1
    fi
fi

if [[ -z "$CONDA_DEFAULT_ENV" || "$CONDA_DEFAULT_ENV" == "base" || -z "$CONDA_PREFIX" || ! -x "$CONDA_PREFIX/bin/python" ]]; then
    echo "ERROR: A non-base conda environment with Python must be activated before updating."
    exit 1
fi
env_python="$CONDA_PREFIX/bin/python"
echo "Updating development MNE repositories..."
echo "Current environment: $CONDA_DEFAULT_ENV"
echo "Environment path: $CONDA_PREFIX"

if ! command -v git &> /dev/null; then
    echo "ERROR: git was not found on PATH."
    exit 1
fi

failed=()

# Usage: update_repo <name> <path> <extras>
update_repo() {
    local name="$1"
    local path="$2"
    local extras="$3"

    echo
    echo "=================================================="
    echo "Updating $name"
    echo "=================================================="

    if [[ -z "$path" ]]; then
        echo "Path for $name not specified in paths.ini, skipping..."
        return
    fi
    if [[ ! -d "$path" ]]; then
        echo "Warning: $name directory not found at $path, skipping..."
        return
    fi

    cd "$path" || { failed+=("$name (cd)"); return; }

    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo "Warning: $path is not a git repository, skipping git update..."
    else
        local remote=""
        if git remote | grep -qx "upstream"; then
            remote="upstream"
        elif git remote | grep -qx "origin"; then
            remote="origin"
        fi

        if [[ -z "$remote" ]]; then
            echo "Warning: Neither 'upstream' nor 'origin' remote found, skipping git update..."
        else
            echo "Fetching all remotes..."
            if ! git fetch --all --prune; then
                echo "Warning: Fetching failed for $name"
                failed+=("$name (fetch)")
            fi

            # Determine default branch of the chosen remote
            local ref
            ref=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2> /dev/null)
            if [[ -z "$ref" ]]; then
                git remote set-head "$remote" --auto &> /dev/null
                ref=$(git symbolic-ref --quiet --short "refs/remotes/$remote/HEAD" 2> /dev/null)
            fi
            if [[ -z "$ref" ]]; then
                for b in main master; do
                    if git show-ref --verify --quiet "refs/remotes/$remote/$b"; then
                        ref="$remote/$b"
                        break
                    fi
                done
            fi

            local current
            current=$(git branch --show-current)
            if [[ -z "$ref" ]]; then
                echo "Warning: Could not determine default branch of '$remote', skipping merge..."
                failed+=("$name (default branch)")
            elif [[ -z "$current" ]]; then
                echo "Warning: Repository is in detached HEAD state, skipping merge..."
                failed+=("$name (detached HEAD)")
            else
                echo "Merging $ref into $current..."
                if ! git merge --no-edit --autostash "$ref"; then
                    echo "Warning: Merge of $ref into $current failed, aborting merge..."
                    git merge --abort &> /dev/null
                    failed+=("$name (merge)")
                fi
            fi
        fi
    fi

    echo "Renewing editable installation of $name..."
    if ! "$env_python" -m pip install -e ".[$extras]"; then
        echo "Warning: Editable installation of $name failed"
        failed+=("$name (pip install)")
    fi
}

update_repo "mne-python" "$mne_python_path" "full-no-qt,test,doc"
update_repo "mne-qt-browser" "$mne_qt_browser_path" "opengl,tests"
update_repo "mne-bids" "$mne_bids_path" "full,test,doc"
update_repo "mne-bids-pipeline" "$mne_bids_pipeline_path" "full,test,doc"
update_repo "mne-connectivity" "$mne_connectivity_path" "test,doc"
update_repo "mne-features" "$mne_features_path" "test,doc"
update_repo "mne-nodes" "$mne_nodes_path" "test,docs,plugins"

echo
if [[ ${#failed[@]} -eq 0 ]]; then
    echo "All repositories updated successfully!"
else
    echo "Update finished with problems in:"
    for f in "${failed[@]}"; do
        echo "  - $f"
    done
fi
echo
echo "Printing System-Info:"
"$env_python" -c "import mne; mne.sys_info()"
