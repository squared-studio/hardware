#!/bin/bash

################################################################################
# FUNCTIONS
################################################################################

ci_simulate () {
  start_time=$(date +%s)
  echo -n -e " $(date +%d/%m/%Y\ %H:%M:%S) - \033[1;33mSIMULATING $1 $2... \033[0m"
  make simulate TOP=$1 TEST=$2 > /dev/null 2>&1
  end_time=$(date +%s)
  time_diff=$((end_time - start_time))
  echo -e "\033[1;32mDone!\033[0m ($time_diff seconds)"
}

################################################################################
# CLEANUP
################################################################################

start_time=$(date +%s)
clear
make -s print_logo
echo -n -e " $(date +%d/%m/%Y\ %H:%M:%S) - \033[1;33mCLEANING UP TEMPORATY FILES... \033[0m"
make -s clean_full > /dev/null 2>&1
end_time=$(date +%s)
time_diff=$((end_time - start_time))
echo -e "\033[1;32mDone!\033[0m ($time_diff seconds)"

################################################################################
# SIMULATE
################################################################################

ci_simulate clk_div_tb default

################################################################################
# COLLECT & PRINT
################################################################################

rm -rf temp_ci_issues
touch temp_ci_issues

grep -s -r "TEST FAILED" ./log | sed "s/.*\.log://g" >> temp_ci_issues
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g" >> temp_ci_issues
grep -s -r "Fatal:" ./log | sed "s/.*\.log://g" >> temp_ci_issues

echo -e ""
echo -e "\033[1;36m___________________________ CI REPORT ___________________________\033[0m"
grep -s -r "TEST PASSED" ./log | sed "s/.*\.log://g"
grep -s -r "TEST FAILED" ./log | sed "s/.*\.log://g"
grep -s -r "WARNING:" ./log | sed "s/.*\.log://g"
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g"
grep -s -r "Fatal:" ./log | sed "s/.*\.log://g"

echo -e "\n"
echo -e "\033[1;36m____________________________ SUMMARY ____________________________\033[0m"
echo -n "PASS    : "
grep -s -r "TEST PASSED" ./log | sed "s/.*\.log://g" | wc -l
echo -n "FAIL    : "
grep -s -r "TEST FAILED" ./log | sed "s/.*\.log://g" | wc -l
echo -n "WARNING : "
grep -s -r "WARNING:" ./log | sed "s/.*\.log://g" | wc -l
echo -n "ERROR   : "
grep -s -r "ERROR:" ./log | sed "s/.*\.log://g" | wc -l
echo -n "Fatal   : "
grep -s -r "Fatal:" ./log | sed "s/.*\.log://g" | wc -l
echo -e ""
