#!/bin/bash
# gfpw - A script to generate random passwords with robust error handling
# Version 2.4 - Safe, secure, and crash-resistant

CONFIG_FILE="/etc/gfpw/gfpw.yaml"
DEFAULT_PROFILE="strong"

# Character sets
upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
lower="abcdefghijklmnopqrstuvwxyz"
numbers="0123456789"
special_cisco='~`!@#$%^&*()-_+={}[]|\;:"<>,./?'
special_default='!@#$%^&*()_+=-[]{}|;:,.<>?'

# Default values
length=16
include_upper=true
include_lower=true
include_number=true
include_special=true
special_set="$special_cisco"  # Default to Cisco special chars
password_count=1  # Default to generating 1 password unless -m is specified

# Error handler function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Trap for cleanup on script termination (Ctrl+C or unexpected exits)
trap 'error_exit "Unexpected termination or interruption detected."' SIGINT SIGTERM

# Check if required utilities are available
command -v gpg >/dev/null 2>&1 || error_exit "gpg is required but not installed."
command -v tr >/dev/null 2>&1 || error_exit "tr is required but not installed."
command -v shuf >/dev/null 2>&1 || error_exit "shuf is required but not installed."

# Function to parse YAML
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*:[[:space:]]*'
   local w='[a-zA-Z0-9_]*'
   local fs="$(echo @|tr @ '\034')"
   sed -ne "s|^\($w\)$s\(.*\)$|$prefix\1$fs\2|p" "$1" |
   awk -F"$fs" '{
      gsub(/"/, "", $2);
      gsub(/'\''/, "", $2);  # Correct single-quote handling
      printf("%s%s=\"%s\"\n", "'"$prefix"'", $1, $2);
   }' || error_exit "Failed to parse YAML configuration."
}

# Load configuration profile from YAML
load_profile() {
    local profile=$1
    eval "$(parse_yaml "$CONFIG_FILE" "")"
    
    if [[ -z "$profile" || -z "${!profile}" ]]; then
        echo "Warning: Profile '$profile' not found. Using default '$DEFAULT_PROFILE'."
        profile=$DEFAULT_PROFILE
    fi

    min_length=$(eval echo \${${profile}_length_min:-12})
    max_length=$(eval echo \${${profile}_length_max:-20})
    include_upper=$(eval echo \${${profile}_characters_upper:-true})
    include_lower=$(eval echo \${${profile}_characters_lower:-true})
    include_number=$(eval echo \${${profile}_characters_number:-true})
    include_special_all=$(eval echo \${${profile}_characters_special_all:-false})
    include_special_cisco=$(eval echo \${${profile}_characters_special_cisco:-true})

    # Determine the special character set
    if [[ "$include_special_cisco" == "true" ]]; then
        special_set="$special_cisco"
    elif [[ "$include_special_all" == "true" ]]; then
        special_set="$special_default"
    else
        special_set=""
    fi

    # Validate and set a random length within the min-max range
    if [[ -n "$min_length" && -n "$max_length" ]]; then
        if [[ "$min_length" -le "$max_length" && "$min_length" -ge 1 ]]; then
            length=$((RANDOM % (max_length - min_length + 1) + min_length))
        else
            error_exit "Invalid length range in the profile."
        fi
    fi
}

# Help function
show_help() {
    echo "Usage: gfpw [options] [profile]"
    echo "Options:"
    echo "  -l {integer}       Specify password length (overrides profile length)"
    echo "  -u                 Include uppercase letters"
    echo "  -L                 Include lowercase letters"
    echo "  -n                 Include numbers"
    echo "  -s                 Include special characters"
    echo "  -m {integer}       Specify the number of passwords to generate (required)"
    echo "  -h                 Show this help message"
    echo "  profile            Specify a profile from the config file (default: strong)"
}

# Parse command-line options
while getopts "l:uLnsm:h" opt; do
    case $opt in
        l) 
            [[ "$OPTARG" =~ ^[0-9]+$ ]] && length=$OPTARG || error_exit "Invalid length specified."
            ;;
        u) include_upper=true ;;
        L) include_lower=true ;;
        n) include_number=true ;;
        s) include_special=true ;;
        m)
            [[ "$OPTARG" =~ ^[0-9]+$ ]] && password_count=$OPTARG || error_exit "Invalid number of passwords specified. The -m option requires an integer argument."
            ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done
shift $((OPTIND-1))

# Load profile from the config file
profile=${1:-$DEFAULT_PROFILE}
if [[ -f "$CONFIG_FILE" ]]; then
    load_profile "$profile"
else
    echo "Warning: Config file $CONFIG_FILE not found. Using default settings."
fi

# Build the character set based on options and profile
charset=""
[[ "$include_upper" == true ]] && charset+="$upper"
[[ "$include_lower" == true ]] && charset+="$lower"
[[ "$include_number" == true ]] && charset+="$numbers"
[[ "$include_special" == true && -n "$special_set" ]] && charset+="$special_set"

# Ensure that at least one character set is chosen
[[ -z "$charset" ]] && error_exit "You must include at least one character set (use -u, -L, -n, -s options or config file)."

# Function to generate a password
generate_password() {
    password=$(gpg --gen-random 1 $((length * 2)) | tr -dc "$charset" | head -c "$length" || error_exit "Failed to generate a random password.")
    
    # Ensure it meets the minimum requirement (at least one of each if enabled)
    [[ "$include_upper" == true && ! "$password" =~ [A-Z] ]] && password="${upper:RANDOM%${#upper}:1}$password"
    [[ "$include_lower" == true && ! "$password" =~ [a-z] ]] && password="${lower:RANDOM%${#lower}:1}$password"
    [[ "$include_number" == true && ! "$password" =~ [0-9] ]] && password="${numbers:RANDOM%${#numbers}:1}$password"
    [[ "$include_special" == true && ! "$password" =~ [\~\`\!\@\#\$\%\^\&\*\(\)\_\+\=\-\[\]\{\}\|\;\:\,\.\<\>\?] ]] && password="${special_set:RANDOM%${#special_set}:1}$password"
    
    # Shuffle the password to ensure randomness
    password=$(echo "$password" | fold -w1 | shuf | tr -d '\n') || error_exit "Failed to shuffle the password."
    
    echo "$password"
}

# Generate the requested number of passwords
for ((i = 0; i < password_count; i++)); do
    generate_password
done
