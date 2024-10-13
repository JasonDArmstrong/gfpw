# gfpw

A Bash script to generate random passwords with configurable password policies. Supports specifying password length, character sets, and the number of passwords to generate, with cryptographically secure randomness provided by gpg

```markdown
# GFPW - A Random Password Generator

`gfpw.sh` is a Bash script designed to generate random passwords with configurable password policies. The script supports various options such as specifying the length of passwords, the number of passwords to generate, and the inclusion of character types (uppercase, lowercase, numbers, and special characters).

## Features

- Generate random passwords using the `gpg` command for cryptographic randomness.
- Configurable through YAML profiles.
- Command-line options to specify password length, character sets, and number of passwords to generate.
- Includes upper/lowercase letters, numbers, and special characters based on user input.
- Supports default and custom profiles for password policies.

## Prerequisites

Ensure that the following utilities are installed on your system:

- `gpg` (for cryptographic random generation)
- `tr` (to filter characters)
- `shuf` (for shuffling password characters)

You can install them with:

```bash
# On Debian/Ubuntu-based systems
sudo apt install gnupg coreutils

# On RedHat/CentOS-based systems
sudo yum install gnupg coreutils
```

## Usage

The script can be used in multiple ways, depending on your requirements.

### Basic Usage

Generate a single password with default settings:

```bash
./gfpw.sh
```

### Specifying a Profile

Generate a password using a predefined profile (e.g., `strong`):

```bash
./gfpw.sh strong
```

### Command-Line Options

- **Specify Password Length:**
  
  You can specify the length of the password using the `-l` option:

  ```bash
  ./gfpw.sh -l 16
  ```

- **Specify Number of Passwords:**

  Generate multiple passwords using the `-m` option:

  ```bash
  ./gfpw.sh -m 5
  ```

- **Include Uppercase, Lowercase, Numbers, and Special Characters:**

  You can control which character sets to include:

  ```bash
  ./gfpw.sh -u -L -n -s
  ```

  - `-u` - Include uppercase letters.
  - `-L` - Include lowercase letters.
  - `-n` - Include numbers.
  - `-s` - Include special characters.

### Help

To display help information for the script:

```bash
./gfpw.sh -h
```

## Example Commands

Here are a few example commands you can run to test different functionality:

- Generate 10 passwords of length 12 with all character types:
  
  ```bash
  ./gfpw.sh -l 12 -m 10 -u -L -n -s
  ```

- Generate a password with only uppercase letters:

  ```bash
  ./gfpw.sh -u -L false -n false -s false
  ```

- Generate 3 passwords of length 16 with uppercase and numbers only:

  ```bash
  ./gfpw.sh -l 16 -m 3 -u -n -L false -s false
  ```

## Error Handling

The script includes robust error handling. If any command fails (such as missing required utilities), the script will output an error message and exit. Some common errors include:

- Missing configuration file: If the YAML configuration file is not found, the script will fall back to default settings.
- Invalid inputs: The script checks for valid password length, number of passwords, and character sets.

## License

This project is open-source and available under the MIT License.

---

Feel free to modify or extend this project as needed for your own use cases!

### Changes made

- **Removed references to the test script** and testing process.
- Retained sections on **features, usage**, and **error handling** to keep the focus on the functionality of the `gfpw.sh` script.

This version is ready to be uploaded to GitHub!
