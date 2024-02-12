dragen  := "./result/bin/dragen-os"

test_segfault: # test_data build_reference
    {{dragen}} -r dragmap --RGSM test --num-threads 2 -1 SRX882903_T2.fastq.gz > output.log

build_reference: test_data
    # mkdir dragmap
    {{dragen}} \
        --build-hash-table true \
        --ht-reference GRCh38_chr21.fa \
        --output-directory dragmap \
        --ht-num-threads 2

test_data:
    wget https://raw.githubusercontent.com/nf-core/test-datasets/nascent/testdata/SRX882903_T2.fastq.gz
    wget https://raw.githubusercontent.com/nf-core/test-datasets/nascent/reference/GRCh38_chr21.fa
