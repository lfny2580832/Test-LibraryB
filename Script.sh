#!/bin/sh

#  Script.sh
#  LibB
#
#  Created by didiniuyan on 2020/12/23.
#  Copyright © 2020 didi. All rights reserved.


echo "开始合成LibB静态库"

#if [ "${ACTION}" = "build" ]
##then

SRCROOT=$(pwd)
#要build的target名，=========此处需指定========
target_Name=LibB
echo "target_Name=${target_Name}"

#build之后的文件夹路径
build_DIR=${SRCROOT}/build
echo "build_DIR=${build_DIR}"

#真机build生成的头文件的文件夹路径
DEVICE_DIR_INCLUDE=${build_DIR}/Release-iphoneos/include/${target_Name}

#真机build生成的.a文件路径
DEVICE_DIR_A=${build_DIR}/Release-iphoneos/lib${target_Name}.a

#模拟器build生成的.a文件路径
SIMULATOR_DIR_A=${build_DIR}/Release-iphonesimulator/lib${target_Name}.a

#目标文件夹路径，=========此处需指定========
INSTALL_DIR=${SRCROOT}/../LibBFramework

#目标头文件文件夹路径
INSTALL_DIR_Headers=${INSTALL_DIR}/Headers
echo "INSTALL_DIR_Headers=${INSTALL_DIR_Headers}"

#目标.a路径
INSTALL_DIR_A=${INSTALL_DIR}/lib${target_Name}.a
echo "INSTALL_DIR_A=${INSTALL_DIR_A}"

#判断build文件夹是否存在，存在则删除
if [ -d "${build_DIR}" ]
then
rm -rf "${build_DIR}"
fi

#判断目标文件夹是否存在，存在则删除该文件夹
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi

#创建目标文件夹
mkdir -p "${INSTALL_DIR}"

#build之前clean一下
xcodebuild -target ${target_Name} clean

#模拟器build
xcodebuild -target ${target_Name} -configuration Release -sdk iphonesimulator

#真机build
xcodebuild -target ${target_Name} -configuration Release -sdk iphoneos

#复制头文件到目标文件夹
cp -R "${DEVICE_DIR_INCLUDE}" "${INSTALL_DIR_Headers}"

#xcode12需要移除模拟器.a的arm64架构
XCODE_VERSION=$(xcodebuild -version | grep Xcode |awk -F " " '{print $2}')
echo "XCODE_VERSION=${XCODE_VERSION}"

if [ `echo "$XCODE_VERSION >= 12.0" | bc` -eq 1 ]
then
  echo "xcodebuild命令行工具是在xcode12版本后的，生成的模拟器.a需移除arm64架构"
  lipo -remove arm64 "${SIMULATOR_DIR_A}" -output "${SIMULATOR_DIR_A}"
else
  echo "模拟器.a无需移除arm64架构"
fi

#合成模拟器和真机.a包
lipo -create "${DEVICE_DIR_A}" "${SIMULATOR_DIR_A}" -output "${INSTALL_DIR_A}"

#删除build文件夹
rm -rf "${build_DIR}"
