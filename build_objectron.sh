#!/bin/bash

set -e

export GLOG_logtostderr=1
# GG: Bug workaround
export PYTHON_BIN_PATH="C:\Program Files\Python310\python.exe"

# GG: Set this to one of the following: {'Shoe', 'Chair', 'Cup', 'Camera'}
object="Chair"

# GG: Set the path of these variables
input_video="my-videos/Source-Chair.mp4"
output_video="my-videos/Output-Chair.mp4"
# input_video="mediapipe/examples/desktop/object_detection/test_video.mp4"
# output_video="my-videos/output_test_video.mp4"

out_dir="my-objectron-bin"
app_name="object_detection_3d"
app="mediapipe/examples/desktop/object_detection_3d"
target_name="objectron"
target="${app}:${target_name}_cpu"
bin_dir="bazel-bin"
build_only=false
run_only=false
declare -a default_bazel_flags=(build -c opt --define MEDIAPIPE_DISABLE_GPU=1)
declare -a bazel_flags
bazel_flags=("${default_bazel_flags[@]}")
bazel_flags+=(${target})

while [[ -n $1 ]]; do
  case $1 in
    -d)
      shift
      out_dir=$1
      ;;
    -b)
      build_only=true
      ;;
    -r)
      run_only=true
      ;;
    -i)
      input_video="$1"
      ;;
    -o)
      output_video="$1"
      ;;
    -j)
      object="$1"
      ;;
    *)
      echo "Unsupported input argument $1."
      exit 1
      ;;
  esac
  shift
done

object="$( tr '[:upper:]' '[:lower:]' <<<"$object" )"

case "$object" in
  shoe)
    object="Shoe"
    landmark_model="object_detection_3d_sneakers.tflite"
    label="Footwear"
    ;;
  chair)
    object="Chair"
    landmark_model="object_detection_3d_chair.tflite"
    label="Chair"
    ;;
  cup)
    object="Cup"
    landmark_model="object_detection_3d_camera.tflite"
    label="Camera"
    ;;
  camera)
    object="Camera"
    landmark_model="object_detection_3d_cup.tflite"
    label="Mug"
    ;;
  *)
    echo "Unsupported input argument $object."
    exit 1
    ;;
esac

echo "app: $app"
echo "out_dir: $out_dir"
echo "object: $object"

# GG: Create the output directory if missing
if [[ ! -d "${out_dir}" ]]; then
    mkdir -p "${out_dir}"
fi

if [[ -d "${app}" ]]; then
  echo "=== Target: ${target}"

  if [[ $run_only == false ]]; then
    bazelisk "${bazel_flags[@]}"
    # GG: Patch missing .exe
    cp -f "${bin_dir}/${app}/"*"_cpu.exe" "${out_dir}"
  fi

  if [[ $build_only == false ]]; then
    graph_name="${app_name}/${target_name}"
    graph_suffix="desktop_cpu"

    # #GG: Try running it without "input_video_path" and "output_video_path"
    # GLOG_logtostderr=1 "${out_dir}/${target_name}_cpu.exe" \
      # --calculator_graph_config_file=mediapipe/graphs/"${graph_name}_${graph_suffix}.pbtxt" \
      # --input_side_packets="box_landmark_model_path=mediapipe/modules/objectron/${landmark_model},allowed_labels=${label}"
    # GG: Patch missing .exe
    GLOG_logtostderr=1 "${out_dir}/${target_name}_cpu.exe" \
      --calculator_graph_config_file=mediapipe/graphs/"${graph_name}_${graph_suffix}.pbtxt" \
      --input_side_packets="input_video_path=${input_video},box_landmark_model_path=mediapipe/modules/objectron/${landmark_model},output_video_path=${output_video},allowed_labels=${label}"
  fi
fi
