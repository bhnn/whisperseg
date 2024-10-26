#!/bin/bash

base_dir="/usr/users/bhenne/projects/whisperseg"
source_dir="$base_dir"/data/data_backup
dest_dir="$base_dir"/data/lemur_setup
dest_name="9call_balanced_other"

rm -f "$source_dir"/finetune_balanced/*
rm -f "$source_dir"/pretrain_balanced/*

# prep
python util/make_json.py -p $source_dir/finetune -t 0.5 -d 2.5 -o $source_dir/finetune -a animal_filter_replace -f w up mo h hw d hu wa t --merge_targets
python util/make_json.py -p $source_dir/finetune -t 0.5 -d 2.5 -o $source_dir/pretrain -a animal
python util/trim_wavs.py -p $source_dir/finetune -S
python util/trim_wavs.py -p $source_dir/pretrain -S
python util/balance_cuts.py -p $source_dir/finetune -s 30 -o $source_dir/finetune_balanced
python util/balance_cuts.py -p $source_dir/pretrain -s 30 -o $source_dir/pretrain_balanced

files=(
    "\(2019_03_15-12_02_11\)_CSWMUW240241_0000_first*"
    "\(2019_03_15-12_02_11\)_CSWMUW240241_0001_first*"
    "\(2021_01_17-03_53_54\)_ASWMUX209084_0003_first*"
    "\(2021_04_21-19_04_26\)_ASWMUX209084_0000_first*"
    "\(2023_10_05-09_05_06\)_ASWMUX208980_0017_second*"
    "\(2023_10_10-12_07_50\)_CSWMUW240241_0001_second*"
    "\(2023_10_18-10_06_01\)_ASWMUX209146_0024_second*"
)

cfg_count=1

for test_file in "${files[@]}"; do
    # reset lemur_setup to default
    rm -f "$dest_dir"/pretrain/*
    rm -f "$dest_dir"/finetune/*
    rm -f "$dest_dir"/test/*
    cp "$source_dir"/pretrain_balanced/*.json "$dest_dir"/pretrain/
    cp "$source_dir"/finetune_balanced/*.json "$dest_dir"/finetune/

    # split up test file
    mv "$dest_dir"/pretrain/$test_file "$dest_dir"/test
    mv "$dest_dir"/finetune/$test_file "$dest_dir"/test

    # create tar
    cd "$dest_dir"
    tar -cf "lemur_labels_cfg${cfg_count}_${dest_name}.tar" *
    mv "$dest_dir"/lemur_labels* "$base_dir/data/lemur_tar/labels_${dest_name}"
    ((cfg_count++))
done

cfg_count=1

for test_file in "${files[@]}"; do
    # reset lemur_setup to default
    rm -f "$dest_dir"/pretrain/*
    rm -f "$dest_dir"/finetune/*
    rm -f "$dest_dir"/test/*
    cp "$source_dir"/pretrain_balanced/*.wav "$dest_dir"/pretrain/
    cp "$source_dir"/finetune_balanced/*.wav "$dest_dir"/finetune/

    # split up test file
    mv "$dest_dir"/pretrain/$test_file "$dest_dir"/test
    mv "$dest_dir"/finetune/$test_file "$dest_dir"/test

    # create tar
    cd "$dest_dir"
    tar -cf "lemur_data_cfg${cfg_count}_${dest_name}.tar" *
    mv "$dest_dir"/lemur_data* "$base_dir/data/lemur_tar/data_${dest_name}"
    ((cfg_count++))
done