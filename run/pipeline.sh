#!/bin/bash
cd ../data/fastqs/
SECONDS=0
ScaAccListFile="../SraAccList.txt"

dialog_choice(){
	HEIGHT=15
	WIDTH=40
	CHOICE_HEIGHT=6
	BACKTITLE="Backtitle here"
	TITLE="Title here"
	MENU="Choose one of the following options:"

	OPTIONS=(1 SRR13970433
			2 SRR13970434
			3 SRR13970435
			4 SRR13970436
			5 SRR13970437
			6 SRR13970438
			7 SRR13970439
			8 SRR13970440
			9 SRR13970441
			10 SRR13970442
			11 SRR13970443
			12 SRR13970444
			13 SRR13970445
			14 SRR13970446
			15 SRR13970447
			16 SRR13970448)

	CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
	                --title "$TITLE" \
	                --menu "$MENU" \
	                $HEIGHT $WIDTH $CHOICE_HEIGHT \
	                "${OPTIONS[@]}" \
	                2>&1 >/dev/tty)

	clear
	case $CHOICE in
	        1)
	            n=$(sed '1q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	        2)
	            n=$(sed '2q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	        3)
	            n=$(sed '3q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	        4)
	            n=$(sed '4q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	        5)
	            n=$(sed '5q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	        6)
	            n=$(sed '6q;d' $ScaAccListFile)
	            fqless "$n.fastq"
	            echo "$n.fastq file closed"
	            ;;
	esac
}

if [[ $1 = "-h" || -z $1 ]]
then
	echo "Help!"
	echo "Different modes:"
	echo "    - 0 = Fastq files download"
	echo "    - 1 = FastQLess quick peak"
	echo "    - 2 = fastqc - quality control"
	echo "    - 3 = Mapping index generation with Salmon"
	echo "    - 4 = alignment."
	echo "    - 5 = Fastp"
fi

# MODE 0 - fastq downlad
# download fastq files from SRA (https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=698121)
if [[ $1 = "0" ]]
then
while read acc; do
	if [[ -f "$acc.fastq" ]]
	then
		echo "This file already exists."
	else
		fasterq-dump --split-spot $acc -vv
		echo "$acc fastq file downloaded"
	fi
done < $ScaAccListFile
fi

# MODE 1 - fqless show
if [[ $1 = "1" ]]
then
	dialog_choice
fi

# MODE 2 - fastqc Quality Controll
if [[ $1 = "2" ]]
then
	echo "FastQC started."
	fastqc *.fastq -o ../../qc
	echo "FastQC ended."
fi

# MODE 3 - Mapping index gen
if [[ $1 = "3" ]]
then
	cd ../reference/reference_ecoli_k12/
	echo "Mapping index generation"
	salmon index -t "cds_from_genomic.fna" -i "../../../map/index"
	echo "Mapping ended."
fi

# MODE 4 - Mapping salmon quant
if [[ $1 = "4" ]]
then
	echo "Mapping quantification"
	for i in {1..16}
	do
		pwd
		seq=$(sed "$i"'q;d' $ScaAccListFile)
		mkdir "../../map/alignment/$seq"
		echo "$seq.fastq"
		salmon quant -i "../../map/index" -l A -r "$seq.fastq" -g "../reference/reference_ecoli_k12/genomic.gtf" --validateMappings -o "../../map/alignment/$seq" -p 12
	done
	echo "Mapping ended."
fi

if [[ $1 = "5" ]]
then
	mkdir "../trimmed"
	echo "Fastp trimming"
	for i in {0..16}
	do
		seq=$(sed "$i"'q;d' $ScaAccListFile)
		echo "$seq.fastq trimming"
		./../../install/fastp -i "$seq.fastq" -h "../trimmed/$seq""report.html" -o "../trimmed/$seq""_trimmed.fastq" 
	done
	echo "Mapping ended."
fi


# measure runtime
duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
echo "END"