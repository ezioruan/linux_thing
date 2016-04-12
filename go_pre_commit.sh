#!/bin/bash
#
# Check a "few" things to help write more maintainable Go code.
# 
# OK, it's fairly comprehensive. So simply remove or comment out
# anything you don't want.
# 
# Don't forget to install (go get) each of these tools.
# More info at the URLs provided.
#
set -e

RED='\033[0;31m'
LPURPLE='\033[1;35m'
DGRAY='\033[1;30m'
NC='\033[0m' # No Color

declare total_issues=0

# Golint (all files)
# https://github.com/golang/lint
declare lint_result=$(golint ./...)
if [[ $lint_result ]]; then
    lint_count=$(wc -l <<< "$lint_result")
    total_issues=$(($total_issues+$lint_count))

    # If there are a bunch of issues, change the color of the count.
    if [ $lint_count -gt 10 ]; then
        printf "${LPURPLE}Golint${RED} (${lint_count// })${NC}\n"
    else
        printf "${LPURPLE}Golint${NC} (${lint_count// })\n"
    fi
    # normal
    # printf "$lint_result"
    # dim the file path and line numbers
    echo "$lint_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi

# Dependency sanity check (replace the message about running with -v option to avoid confusion)
# https://github.com/divan/depscheck
# NOTE: This only checks dependencies in current directory (run from root)
declare depscheck_result=$(depscheck . | sed -e "s/Run with -v option to see detailed stats for dependencies.//g")
if [[ $depscheck_result ]]; then
    depscheck_count=$(echo "$depscheck_result" | grep -cE "good candidate")
    total_issues=$(($total_issues+$depscheck_count))

    # If there are a bunch of barely used dependencies, change the color of the count.
    if [ $depscheck_count -gt 5 ]; then
        printf "${LPURPLE}Depscheck${RED} (${depscheck_count// })${NC}\n"
    else
        printf "${LPURPLE}Depscheck${NC} (${depscheck_count// })\n"
    fi  
    printf "$depscheck_result\n\n"
fi

# Interfacer warns about the usage of types that are more specific than necessary.
# https://github.com/mvdan/interfacer
declare interface_lint_result=$(interfacer ./...)
if [[ $interface_lint_result ]]; then
    interface_lint_count=$(wc -l <<< "$interface_lint_result")
    total_issues=$(($total_issues+$interface_lint_count))

    # If there are a bunch of issues, change the color of the count.
    if [ $interface_lint_count -gt 5 ]; then
        printf "${LPURPLE}Interfacer${RED} (${interface_lint_count// })${NC}\n"
    else
        printf "${LPURPLE}Interfacer${NC} (${interface_lint_count// })\n"
    fi
    # normal
    # printf "$interface_lint_result"
    # dim the file path and line numbers
    echo "$interface_lint_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi

# structcheck warns about unused struct fields.
# https://github.com/opennota/check/
declare structcheck_result=$(structcheck ./...)
if [[ $structcheck_result ]]; then
    structcheck_count=$(wc -l <<< "$structcheck_result")
    total_issues=$(($total_issues+$structcheck_count))

    # If there are a bunch of issues, change the color of the count.
    if [ $structcheck_count -gt 5 ]; then
        printf "${LPURPLE}Unused struct fields${RED} (${structcheck_count// })${NC}\n"
    else
        printf "${LPURPLE}Unused struct fields${NC} (${structcheck_count// })\n"
    fi
    # normal
    # printf "$structcheck_result"
    # dim the file path and line numbers
    echo "$structcheck_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi

# varcheck warns about unused global variables and constants.
# https://github.com/opennota/check/
declare varcheck_result=$(varcheck ./...)
if [[ $varcheck_result ]]; then
    varcheck_count=$(wc -l <<< "$varcheck_result")
    total_issues=$(($total_issues+$varcheck_count))

    # If there are a bunch of issues, change the color of the count.
    if [ $varcheck_count -gt 3 ]; then
        printf "${LPURPLE}Unused variables and constants${RED} (${varcheck_count// })${NC}\n"
    else
        printf "${LPURPLE}Unused variables and constants${NC} (${varcheck_count// })\n"
    fi
    # normal
    # printf "$varcheck_result"
    # dim the file path and line numbers
    echo "$varcheck_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi

# errcheck warns about unchecked errors in your code.
# https://github.com/kisielk/errcheck
declare errcheck_result=$(errcheck ./...)
if [[ $errcheck_result ]]; then
    errcheck_count=$(wc -l <<< "$errcheck_result")
    total_issues=$(($total_issues+$errcheck_count))
    printf "${LPURPLE}Unchecked errors${NC} (${errcheck_count// })\n"
    # normal
    # printf "$errcheck_result"
    # dim the file path and line numbers
    echo "$errcheck_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi

# gocyclo reports cyclomatic complexity.
# https://github.com/fzipp/gocyclo
cyclo_tolerance=10
declare cyclo_result=$(gocyclo -over "$cyclo_tolerance" .)
if [[ $cyclo_result ]]; then
    cyclo_count=$(wc -l <<< "$cyclo_result")
    total_issues=$(($total_issues+$cyclo_count))
    printf "${LPURPLE}Cyclomatic complexity above ${cyclo_tolerance}${NC} (${cyclo_count// })\n"
    printf "$cyclo_result\n\n"
fi

# safesql looks for SQL injection vulnerabilities in your code.
# https://github.com/stripe/safesql
declare sqlcheck_result=$(safesql -q .)
if [[ $sqlcheck_result ]]; then
    sqlcheck_count=$(wc -l <<< "$sqlcheck_result")
    total_issues=$(($total_issues+$sqlcheck_count))
    # Always red, not good to have any.
    printf "${LPURPLE}SQL injection warning${RED} (${sqlcheck_count// })${NC}\n"
    # normal
    # printf "$sqlcheck_result"
    echo "$sqlcheck_result" | GREP_COLOR='2;39' grep --color=always -E '^.+[0-9]\:*\s'
    printf "\n\n"
fi


# If there were issues, exit 1
if [ $total_issues -gt 0 ]; then
    # There were some issues that might need attention
    exit 1
fi

exit 0
