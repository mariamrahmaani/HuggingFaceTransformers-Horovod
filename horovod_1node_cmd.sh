#!/bin/sh
export TASK_NAME=MRPC
 
export MAX_SEQ_LENGTH=128

export OMP_NUM_THREADS=40
export HOROVOD_FUSION_THRESHOLD=$((128*1024*1024))
export PER_GPU_EVAL_BATCH_SIZE=64   
export PER_GPU_TRAIN_BATCH_SIZE=64 

#export NUM_NODES=2
#export NUM_WORKERS_PER_NODE=1
#export NUM_WORKERS=$((NUM_NODES * NUM_WORKERS_PER_NODE))
 
#HOSTFILE=~/winter.hosts.$NUM_NODES
#MPI=/home/mariam/OpenMpi.4.0.1/bin/mpiexec

GLUE_DIR=/home/GLUE/GLUE/glue_data/
 
#pssh -h $HOSTFILE -i -P "rm -rf $OUTPUT_DIR/*"
 
horovodrun -np 4 -H localhost:4  python run_glue_horovod.py   --model_type bert   --model_name_or_path ~/bert-checkpoint   --task_name MRPC   --do_train   --do_eval   --do_lower_case   --data_dir ~/GLUE/GLUE/glue_data/MRPC   --max_seq_length 128   --per_gpu_train_batch_size 32   --learning_rate 2e-5   --num_train_epochs 3.0   --output_dir ~/output_dir/MPRC
 
kill -9 $(ps -eaf | grep vmstat | awk '{print $2}')
min=$(cat /tmp/vmstatlog | sed '/memory/d' | sed '/free/d' | awk -v min=9999999999 '{if($4<min){min=$4}}END{print min} ')
top=$(cat /tmp/vmstatlog | sed '/memory/d' | sed '/free/d' | head -n 1 | awk '{print $4}')
echo "Peak memory (KB):" $((top-min))
