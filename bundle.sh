#!/bin/bash

# ComputerCraft Bundling System
# Creates self-contained single-file scripts for easy deployment

set -e

BUNDLES_DIR="bundles"
ARCHIVE_DIR="bundles/archive"
LIB_DIR="lib"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[BUNDLE]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Archive existing bundle if it exists
archive_existing_bundle() {
    local script_name=$1
    local bundle_file="${BUNDLES_DIR}/${script_name}_bundled.lua"
    
    if [ -f "$bundle_file" ]; then
        local timestamp=$(date +"%Y%m%d_%H%M%S")
        local archive_name="${script_name}_bundled_${timestamp}.lua.gz"
        local archive_path="${ARCHIVE_DIR}/${archive_name}"
        
        log "Archiving existing bundle: $archive_name"
        gzip -c "$bundle_file" > "$archive_path"
        success "Archived to: $archive_path"
    fi
}

# Extract dependencies from a script
extract_dependencies() {
    local script_file=$1
    local deps=()
    
    # Find require() calls for our libraries
    while IFS= read -r line; do
        if [[ $line =~ require\(\"(lib\.)?([^\"]+)\"\) ]]; then
            local dep="${BASH_REMATCH[2]}"
            if [ -f "${LIB_DIR}/${dep}.lua" ]; then
                deps+=("$dep")
            fi
        fi
    done < "$script_file"
    
    # Remove duplicates and return
    printf '%s\n' "${deps[@]}" | sort -u
}

# Bundle a single script
bundle_script() {
    local script_name=$1
    local script_file="${script_name}.lua"
    local bundle_file="${BUNDLES_DIR}/${script_name}_bundled.lua"
    
    if [ ! -f "$script_file" ]; then
        error "Script not found: $script_file"
        return 1
    fi
    
    log "Bundling: $script_name"
    
    # Archive existing bundle
    archive_existing_bundle "$script_name"
    
    # Create bundle header
    cat > "$bundle_file" << EOF
-- ============================================================================
-- BUNDLED COMPUTERCRAFT SCRIPT: $script_name
-- Generated: $(date)
-- 
-- This file contains all dependencies bundled for single-file deployment
-- Original files: $script_file + dependencies
-- ============================================================================

EOF
    
    # Extract and bundle dependencies
    local deps=($(extract_dependencies "$script_file"))
    
    if [ ${#deps[@]} -gt 0 ]; then
        echo "-- === BUNDLED DEPENDENCIES ===" >> "$bundle_file"
        echo "" >> "$bundle_file"
        
        for dep in "${deps[@]}"; do
            local dep_file="${LIB_DIR}/${dep}.lua"
            log "  Bundling dependency: $dep"
            
            echo "-- --- DEPENDENCY: $dep.lua ---" >> "$bundle_file"
            
            # Process the dependency file to handle its own requires
            if [ "$dep" = "pickup" ]; then
                # Special handling for pickup.lua which requires movement
                sed 's/local mv = require("lib\.movement")/local mv = movement/g' "$dep_file" >> "$bundle_file"
            else
                cat "$dep_file" >> "$bundle_file"
            fi
            
            echo "" >> "$bundle_file"
        done
        
        echo "-- === END BUNDLED DEPENDENCIES ===" >> "$bundle_file"
        echo "" >> "$bundle_file"
    fi
    
    # Add main script
    echo "-- === MAIN SCRIPT ===" >> "$bundle_file"
    echo "" >> "$bundle_file"
    
    # Process main script to replace require() calls
    local processed_script=$(cat "$script_file")
    
    for dep in "${deps[@]}"; do
        # Replace require calls with direct references
        processed_script=$(echo "$processed_script" | sed "s/require(\"lib\\.$dep\")/\$dep/g")
        processed_script=$(echo "$processed_script" | sed "s/require(\"$dep\")/$dep/g")
    done
    
    echo "$processed_script" >> "$bundle_file"
    
    # Add bundle footer
    cat >> "$bundle_file" << EOF

-- ============================================================================
-- END BUNDLED SCRIPT: $script_name
-- ============================================================================
EOF
    
    success "Created bundle: $bundle_file"
    
    # Show bundle info
    local original_size=$(wc -c < "$script_file")
    local bundle_size=$(wc -c < "$bundle_file")
    local dep_count=${#deps[@]}
    
    log "Bundle info:"
    log "  Original size: $original_size bytes"
    log "  Bundle size: $bundle_size bytes"
    log "  Dependencies: $dep_count (${deps[*]})"
    log "  Ready for ComputerCraft deployment!"
}

# Bundle all scripts
bundle_all() {
    log "Bundling all scripts..."
    
    local scripts=($(find . -maxdepth 1 -name "*.lua" -not -path "./lib/*" -not -path "./test/*" -not -path "./spec/*" -not -path "./bundles/*" | sed 's|^\./||' | sed 's|\.lua$||'))
    
    for script in "${scripts[@]}"; do
        bundle_script "$script"
        echo ""
    done
    
    success "All scripts bundled!"
}

# Watch for changes and auto-bundle
watch_and_bundle() {
    log "Starting file watcher for auto-bundling..."
    log "Watching: *.lua files and lib/*.lua"
    log "Press Ctrl+C to stop"
    
    # Check if inotifywait is available
    if ! command -v inotifywait &> /dev/null; then
        error "inotifywait not found. Install inotify-tools:"
        error "  sudo apt-get install inotify-tools"
        return 1
    fi
    
    # Watch for changes
    inotifywait -m -e modify,create,delete --format '%w%f %e' \
        --include '.*\.lua$' \
        . lib/ 2>/dev/null | while read file event; do
        
        # Skip bundle files and test files
        if [[ "$file" == *"_bundled.lua" ]] || [[ "$file" == *"/test/"* ]] || [[ "$file" == *"/spec/"* ]]; then
            continue
        fi
        
        log "File changed: $file ($event)"
        
        # If it's a library file, rebuild all scripts that depend on it
        if [[ "$file" == lib/* ]]; then
            log "Library changed, rebuilding all scripts..."
            bundle_all
        else
            # If it's a main script, rebuild just that script
            local script_name=$(basename "$file" .lua)
            if [ -f "${script_name}.lua" ]; then
                bundle_script "$script_name"
            fi
        fi
        
        echo ""
    done
}

# Show usage
usage() {
    echo "ComputerCraft Bundling System"
    echo ""
    echo "Usage: $0 [COMMAND] [SCRIPT_NAME]"
    echo ""
    echo "Commands:"
    echo "  bundle <script>    Bundle a specific script (without .lua extension)"
    echo "  bundle-all         Bundle all scripts in current directory"
    echo "  watch             Watch for changes and auto-bundle"
    echo "  list              List available scripts and bundles"
    echo "  clean             Clean all bundles (moves to archive)"
    echo "  help              Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 bundle quarry           # Bundle quarry.lua"
    echo "  $0 bundle treefarm_modded  # Bundle treefarm_modded.lua"
    echo "  $0 bundle-all              # Bundle all scripts"
    echo "  $0 watch                   # Auto-bundle on file changes"
    echo ""
    echo "Output:"
    echo "  Bundles are created in: $BUNDLES_DIR/"
    echo "  Archives are stored in: $ARCHIVE_DIR/"
}

# List available scripts and bundles
list_scripts() {
    log "Available scripts:"
    find . -maxdepth 1 -name "*.lua" -not -path "./lib/*" -not -path "./test/*" -not -path "./spec/*" -not -path "./bundles/*" | sed 's|^\./||' | sort
    
    echo ""
    log "Available bundles:"
    if [ -d "$BUNDLES_DIR" ]; then
        find "$BUNDLES_DIR" -maxdepth 1 -name "*_bundled.lua" | sed 's|^bundles/||' | sort
    else
        echo "  (none)"
    fi
    
    echo ""
    log "Archived bundles:"
    if [ -d "$ARCHIVE_DIR" ]; then
        find "$ARCHIVE_DIR" -name "*.lua.gz" | sed 's|^bundles/archive/||' | sort
    else
        echo "  (none)"
    fi
}

# Clean bundles (move to archive)
clean_bundles() {
    log "Cleaning bundles..."
    
    if [ -d "$BUNDLES_DIR" ]; then
        local count=0
        for bundle in "$BUNDLES_DIR"/*_bundled.lua; do
            if [ -f "$bundle" ]; then
                local basename=$(basename "$bundle")
                local script_name=${basename%_bundled.lua}
                archive_existing_bundle "$script_name"
                rm "$bundle"
                ((count++))
            fi
        done
        
        if [ $count -gt 0 ]; then
            success "Cleaned $count bundles (moved to archive)"
        else
            log "No bundles to clean"
        fi
    else
        log "No bundles directory found"
    fi
}

# Main command handling
case "${1:-help}" in
    "bundle")
        if [ -z "$2" ]; then
            error "Please specify a script name"
            echo "Usage: $0 bundle <script_name>"
            exit 1
        fi
        bundle_script "$2"
        ;;
    "bundle-all")
        bundle_all
        ;;
    "watch")
        watch_and_bundle
        ;;
    "list")
        list_scripts
        ;;
    "clean")
        clean_bundles
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        error "Unknown command: $1"
        usage
        exit 1
        ;;
esac