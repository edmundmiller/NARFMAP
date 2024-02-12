dragen  := "./result/bin/dragen-os"

test_segfault: test_data
    {{dragen}} -r narfmap --RGSM null --num-threads 2 -1 SRX882903_T2.fastq.gz

test_data:
    wget https://raw.githubusercontent.com/nf-core/test-datasets/nascent/testdata/SRX882903_T2.fastq.gz

