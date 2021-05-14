import glob

configfile: "config.yaml"

wildcard_constraints:
   lanenum = '\d+'

inputdirectory=config["directory"]
SAMPLES, LANENUMS = glob_wildcards(inputdirectory+"/{sample}_L{lanenum}_R1_001.fastq.gz", followlinks=True)


##### target rules #####
rule all:
    input: 
       expand('merged/{sample}/{sample}_R1.fastq.gz', sample=SAMPLES),
       expand('merged/{sample}/{sample}_R2.fastq.gz', sample=SAMPLES),
       "qc/multiqc_report_premerge.html",
       "qc/multiqc_report_postmerge.html"

rule mergeFastqR1:
    input: lambda wildcards: sorted(glob.glob(inputdirectory+'/{sample}_L*_R1_001.fastq.gz'.format(sample=wildcards.sample)))
    output: "merged/{sample}/{sample}_R1.fastq.gz"
    shell: "cat {input} > {output}"

rule mergeFastqR2:
    input: lambda wildcards: sorted(glob.glob(inputdirectory+'/{sample}_L*_R2_001.fastq.gz'.format(sample=wildcards.sample)))
    output: "merged/{sample}/{sample}_R2.fastq.gz"
    shell: "cat {input} > {output}"


rule fastqc_premerge_r1:
    input:
        f"{config['directory']}/{{sample}}_L{{lanenum}}_R1_001.fastq.gz"
    output:
        html="qc/fastqc_premerge/{sample}_L{lanenum}_r1.html",
        zip="qc/fastqc_premerge/{sample}_L{lanenum}_r1_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc 
    params: ""
    log:
        "logs/fastqc_premerge/{sample}_L{lanenum}_r1.log"
    threads: 1
    wrapper:
        "v0.69.0/bio/fastqc"

rule fastqc_premerge_r2:
    input:
        f"{config['directory']}/{{sample}}_L{{lanenum}}_R2_001.fastq.gz"
    output:
        html="qc/fastqc_premerge/{sample}_L{lanenum}_r2.html",
        zip="qc/fastqc_premerge/{sample}_L{lanenum}_r2_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc 
    params: ""
    log:
        "logs/fastqc_premerge/{sample}_L{lanenum}_r2.log"
    threads: 1
    wrapper:
        "v0.69.0/bio/fastqc"

rule multiqc_pre:
    input:
        expand("qc/fastqc_premerge/{sample}_L{lanenum}_r1_fastqc.zip", zip, sample=SAMPLES, lanenum=LANENUMS),
        expand("qc/fastqc_premerge/{sample}_L{lanenum}_r2_fastqc.zip", zip, sample=SAMPLES, lanenum=LANENUMS)
    output:
        "qc/multiqc_report_premerge.html"
    log:
        "logs/multiqc_premerge.log"
    wrapper:
        "0.62.0/bio/multiqc"

rule fastqc_postmerge_r1:
    input:
       "merged/{sample}/{sample}_R1.fastq.gz"
    output:
        html="qc/fastqc_postmerge/{sample}_r1.html",
        zip="qc/fastqc_postmerge/{sample}_r1_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: ""
    log:
        "logs/fastqc_postmerge/{sample}_r1.log"
    threads: 1
    wrapper:
        "v0.69.0/bio/fastqc"

rule fastqc_postmerge_r2:
    input:
       "merged/{sample}/{sample}_R2.fastq.gz"
    output:
        html="qc/fastqc_postmerge/{sample}_r2.html",
        zip="qc/fastqc_postmerge/{sample}_r2_fastqc.zip" # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    params: ""
    log:
        "logs/fastqc_postmerge/{sample}_r2.log"
    threads: 1
    wrapper:
        "v0.69.0/bio/fastqc"

rule multiqc_post:
    input:
        expand("qc/fastqc_postmerge/{sample}_r1_fastqc.zip", sample=SAMPLES),
        expand("qc/fastqc_postmerge/{sample}_r2_fastqc.zip", sample=SAMPLES)
    output:
        "qc/multiqc_report_postmerge.html"
    log:
        "logs/multiqc_postmerge.log"
    wrapper:
        "0.62.0/bio/multiqc"
