#!/bin/bash

## TOP LEVEL LINEAGE DIR.. ie:  ~/android/lineage-16.0 or ~/android/lineage-17.1
DIR=`pwd`
cd ${DIR}/../build/
#
# BULDDIR is where the "build" repo is stored.
BUILDDIR=`pwd`
cd ${DIR}
#
cd ${DIR}/../lineageos_UNOFFICIAL/
GDRIVE=`pwd`
cd ${DIR}


#
# I have multiple devices abd bukd for numerous ones, so some may not apply
#
# google: blueline
# asus: I01WD
# us996 h918 h918-10p vs995 ls997 h910 h990ss
# g5: rs988 h830 h850
# g6: h870 us997 h872

LINEAGE=`basename ${DIR}`
echo "Lineage base:   ${LINEAGE}"

SYNC=1
if [ "$1" = "" ] ; then
   echo "DEV usage:      $0 us996 rs988 us997"
   echo "ALL usage:      $0 us996-ds h918 h918-10p vs995 ls997 h910 h990 h830 h850 h870 h872"
   echo "v20 usage:      $0 us996 us996-ds h918 h918-10p vs995 ls997 h910 h990"
   echo " g5 usage:      $0 rs988 h830 h850"
   echo " g6 usage:      $0 us997 h870 h872"
   echo " asus usage:    $0 I01WD"
   echo "google usage:   $0 blueline"
   exit 0
else
   DEVICES="$*"
   SYNC=0
fi

export TZ=GMT
DATE=`date '+%Y%m%d'`

SYNC=0

#
# Private vendor/x86cpu repo exists.

export TARGET_UNOFFICIAL_X86CPU=`grep TARGET_UNOFFICIAL_X86CPU ${DIR}/vendor/x86cpu/BoardConfigExtra.mk | awk '{printf $3}'`
echo "TARGET_UNOFFICIAL_X86CPU set to ${TARGET_UNOFFICIAL_X86CPU}"

LGE=0
PIXEL3=0
ASUS=0

OK=1
for DEVICE in ${DEVICES} ; do
   case "${DEVICE}" in
      h918)
         LGE=1
         ;;
      h918-10p)
         LGE=1
         ;;
      us996)
         LGE=1
         ;;
      us996-O)
         LGE=1
         ;;
      us996-ds)
         LGE=1
         ;;
      vs995)
         LGE=1
         ;;
      ls997)
         LGE=1
         ;;
      h910)
         LGE=1
         ;;
      h830)
         LGE=1
         ;;
      h850)
         LGE=1
         ;;
      h870)
         LGE=1
         ;;
      h872)
         LGE=1
         ;;
      us997)
         LGE=1
         ;;
      rs988)
         LGE=1
         ;;
      h990)
         LGE=1
         ;;
      I01WD)
         ASUS=1
         ;;
      blueline)
         PIXEL3=1
         ;;
      *)
          OK=0
         ;;
   esac
done
# us996 h918 h918-10p vs995 ls997 h910 h830 h850 h870 us997

if [ "${OK}" = "0" ] ; then
   echo "Bad device in list, stopping"
   exit 0
fi

. ${DIR}/.bashrc

#
# Ensure my x86cpu repo is sane and there
if [ ! -d "${DIR}/vendor/extra" ] ; then
   mkdir ${DIR}/vendor/extra
   cp ${BUILDDIR}/vendor-extra-BoardConfigExtra.mk ${DIR}/vendor/extra/BoardConfigExtra.mk
   cp ${BUILDDIR}/vendor-extra-product.mk ${DIR}/vendor/extra/product.mk
fi
if [ -f "${DIR}/vendor/extra/BoardConfigExtra.mk" ] ; then
   if [ `grep -c x86cpu ${DIR}/vendor/extra/BoardConfigExtra.mk` -eq 0 ] ; then
      cp ${BUILDDIR}/vendor-extra-BoardConfigExtra.mk ${DIR}/vendor/extra/BoardConfigExtra.mk
   fi
fi
if [ ! -f "${DIR}/vendor/extra/procuct.mk" ] ; then
   cp ${BUILDDIR}/vendor-extra-BoardConfigExtra.mk ${DIR}/vendor/extra/BoardConfigExtra.mk
fi
if [ -f "${DIR}/vendor/extra/product.mk" ] ; then
   if [ `grep -c x86cpu ${DIR}/vendor/extra/product.mk` -eq 0 ] ; then
      cp ${BUILDDIR}/vendor-extra-product.mk ${DIR}/vendor/extra/product.mk
   fi
fi

# in vendor/x86cpu
# FILE BoardConfigExtra.mk:
#     # My custom signed keys
#     PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/x86cpu/keys/releasekey
#     TARGET_UNOFFICIAL_X86CPU := X86CPU
#     -include vendor/x86cpu/product.mk
#
# FILE product.mk: (NOT NEEDED)
#     # Recovery ADB keys
#     PRODUCT_COPY_FILES += \
#          vendor/x86cpu/adb_keys:root/adb_keys
#

#
# Custom patch to add X86CPU in UNOFFICIAL BUILD NAMES
cd ${DIR}/vendor/lineage
if [ `git log -n 50 | grep -ic TARGET_UNOFFICIAL_X86CPU` -eq 0 ] ; then
   git am ${BUILDDIR}/0001-TARGET_UNOFFICIAL_X86CPU-PATCH.patch
   sleep 2
fi
cd ${DIR}

#
# Add KCAL for LG devices in Kernel
if [ "${LGE}" = "1" ] ; then
   cd ${DIR}/kernel/lge/msm8996
   if [ `git log -n 50 | grep -ic 'KCAL: X86CPU KCAL Patch'` -eq 0 ] ; then
      git am ${BUILDDIR}/0001-KCAL-X86CPU-KCAL-Patch.patch
      sleep 2
   fi
   cd ${DIR}
fi

for DEVICE in ${DEVICES} ; do
   sleep 2
   MYDEV=${DEVICE}
# Google Pixel3, add nano Gapps
   if [ "${DEVICE}" = "blueline" ] ; then
      cd ${DIR}/device/google/crosshatch
      if [ `git log -n 50 | grep -ic gapps` -eq 0 ] ; then
         git am ${BUILDDIR}/0001-DNM-blueline-Add-nano-gapps.patch
         sleep 2
      fi
      cd ${DIR}
   fi
# ASUS Zenfone6, add nano Gapps
   if [ "${DEVICE}" = "I01WD" ] ; then
      cd ${DIR}/device/asus/I01WD
      if [ `git log -n 50 | grep -ic gapps` -eq 0 ] ; then
         git am ${BUILDDIR}/0001-DNM-I01WD-Add-nano-gapps-and-color-temperature.patch
         sleep 2
      fi
      cd ${DIR}
   fi
# Normal us996, N-Firmware
   if [ "${DEVICE}" = "us996" ] ; then
         cp -f ${BUILDDIR}/msm8996-elsa_nao_us-panel.dtsi.us996 ${DIR}/kernel/lge/msm8996/arch/arm64/boot/dts/lge/msm8996-elsa_nao_us/msm8996-elsa_nao_us-panel.dtsi

         cd ${DIR}/device/lge/us996
         git checkout BoardConfig.mk
         /bin/rm board-info.txt
         git apply ${BUILDDIR}/0001-us996-Add-assert-for-20F.patch
         cp -f ${BUILDDIR}/board-info.txt.us996-10p ${DIR}/device/lge/us996/board-info.txt
         cd ${DIR}
   fi
# Normal us996, O-Firmware testing.
   if [ "${DEVICE}" = "us996-O" ] ; then
      cp -f ${BUILDDIR}/msm8996-elsa_nao_us-panel.dtsi.us996 ${DIR}/kernel/lge/msm8996/arch/arm64/boot/dts/lge/msm8996-elsa_nao_us/msm8996-elsa_nao_us-panel.dtsi

      cd ${DIR}/device/lge/us996
      git checkout BoardConfig.mk
      /bin/rm board-info.txt
      git apply ${BUILDDIR}/0001-us996-Add-assert-for-20F.patch

      cd ${DIR}/vendor/lge/v20-common
      git apply ${BUILDDIR}/0001-v20-common-Update-fingerprint-blobs-firmware.patch

      cd ${DIR}/device/lge/msm8996-common
      git apply ${BUILDDIR}/0001-msm8996-Update-fingerprint-HAL-for-Oreo.patch

      cd ${DIR}/device/lge/v20-common
      git apply ${BUILDDIR}/0001-v20-Update-fingerprint-to-2.1-for-Oreo.patch

      cd ${DIR}/kernel/lge/msm8996
      git apply ${BUILDDIR}/0001-msm8996-Update-fingerprint-driver-for-Oreo.patch

      cd ${DIR}
      MYDEV=us996
   fi
# DS = Dirty Santa Model
   if [ "${DEVICE}" = "us996-ds" ] ; then
      cp -f ${BUILDDIR}/msm8996-elsa_nao_us-panel.dtsi.us996-ds ${DIR}/kernel/lge/msm8996/arch/arm64/boot/dts/lge/msm8996-elsa_nao_us/msm8996-elsa_nao_us-panel.dtsi

      cd ${DIR}/device/lge/us996
      git checkout BoardConfig.mk
      /bin/rm board-info.txt
      git apply ${BUILDDIR}/0001-us996-Add-assert-for-20F.patch
      cp -f ${BUILDDIR}/board-info.txt.us996-10p ${DIR}/device/lge/us996/board-info.txt

      cd ${DIR}
      MYDEV=us996
   fi
# h918 device, PRE 10p model
   if [ "${DEVICE}" = "h918" ] ; then
      /bin/rm ${DIR}/out/target/product/h918/system/vendor/firmware/a530*
      cp -f ${BUILDDIR}/h918.a530.pre10p/* ${DIR}/vendor/lge/h918/proprietary/vendor/firmware/
      cp -f ${BUILDDIR}/board-info.txt.h918.pre10p ${DIR}/device/lge/h918/board-info.txt
   fi
# h918 device, POST 10p model (-10p)
   if [ "${DEVICE}" = "h918-10p" ] ; then
      /bin/rm ${DIR}/out/target/product/h918/system/vendor/firmware/a530*
      cp -f ${BUILDDIR}/h918.a530.10p/* ${DIR}/vendor/lge/h918/proprietary/vendor/firmware/
      cp -f ${BUILDDIR}/board-info.txt.h918.10p ${DIR}/device/lge/h918/board-info.txt
      MYDEV=h918
   fi

   if [ -d "${DIR}/out/target/product/${MYDEV}" ] ; then
      cd ${DIR}/out/target/product/${MYDEV}
      /bin/rm -rf obj/PACKAGING/ recovery system root *img *.zip *.zip.md5sum
   fi
   cd ${DIR}

   if [ -x "${BUILDDIR}/notify.sh" ] ; then
      ${BUILDDIR}/notify.sh "${LINEAGE}: START ${DEVICE}"
   fi
# Building the device now
   echo "BUILD: ${DEVICE}"
   cd ${DIR}
   breakfast ${MYDEV}
   brunch ${MYDEV}

   NAME=`ls -rt1 ${DIR}/out/target/product/${MYDEV}/${LINEAGE}-*-X86CPU*.zip | tail -1`
#
# Fixed after build is done
   if [ "${DEVICE}" = "us996-O" ] ; then
      cd ${DIR}/vendor/lge/v20-common
      git checkout . ; rm -rf proprietary/vendor/framework/ proprietary/vendor/lib/vendor.qti.hardware.fingerprint@1.0.so proprietary/vendor/lib64/vendor.qti.hardware.fingerprint@1.0.so

      cd ${DIR}/device/lge/msm8996-common
      git checkout sepolicy/file_contexts rootdir/etc/init.qcom.rc sepolicy/fpc_early_loader.te

      cd ${DIR}/kernel/lge/msm8996
      git checkout arch/arm64/boot/dts/lge/msm8996-fingerprint-fpc1022.dtsi drivers/input/fingerprint

      cd ${DIR}/device/lge/v20-common
      git checkout v20.mk

      cd ${DIR}/device/lge/us996
      git checkout BoardConfig.mk
      /bin/rm board-info.txt

      TMP=`echo "${NAME}" | sed -e's/-us996/-us996-O/'`
      NEW=`basename ${TMP}`
      cp -p ${NAME} ${GDRIVE}/${NEW}
      cat ${NAME}.md5sum | sed -e's/-us996/-us996-O/' > ${GDRIVE}/${NEW}.md5sum
      cd ${DIR}
   elif [ "${DEVICE}" = "us996-ds" ] ; then
      cp -f ${BUILDDIR}/msm8996-elsa_nao_us-panel.dtsi.us996 ${DIR}/kernel/lge/msm8996/arch/arm64/boot/dts/lge/msm8996-elsa_nao_us/msm8996-elsa_nao_us-panel.dtsi

      TMP=`echo "${NAME}" | sed -e's/-us996/-us996-DS/'`
      NEW=`basename ${TMP}`
      cp -p ${NAME} ${GDRIVE}/${NEW}
      cat ${NAME}.md5sum | sed -e's/-us996/-us996-DS/' > ${GDRIVE}/${NEW}.md5sum
   elif [ "${DEVICE}" = "h918" ] ; then
      TMP=`echo "${NAME}" | sed -e's/-h918/-h918-PRE10p/'`
      NEW=`basename ${TMP}`
      cp -p ${NAME} ${GDRIVE}/${NEW}
      cat ${NAME}.md5sum | sed -e's/-h918/-h918-PRE10p/' > ${GDRIVE}/${NEW}.md5sum
      cp -f ${BUILDDIR}/board-info.txt.h918.10p ${DIR}/device/lge/h918/board-info.txt
   elif [ "${DEVICE}" = "h918-10p" ] ; then
      TMP=`echo "${NAME}" | sed -e's/-h918/-h918-10p/'`
      NEW=`basename ${TMP}`
      cp -p ${NAME} ${GDRIVE}/${NEW}
      cat ${NAME}.md5sum | sed -e's/-h918/-h918-10p/' > ${GDRIVE}/${NEW}.md5sum
      cp -f ${BUILDDIR}/h918.a530.pre10p/* ${DIR}/vendor/lge/h918/proprietary/vendor/firmware/
   else
      cp -p ${NAME} ${NAME}.md5sum ${GDRIVE}/
   fi
   if [ ${SYNC} -eq 1 ] ; then
      gdrive sync upload --keep-local --delete-extraneous ${GDRIVE} 0B51rjK5Hd_P5NmpwY1o4VmlyaUk
   fi
   if [ -x "${BUILDDIR}/notify.sh" ] ; then
      ${BUILDDIR}/notify.sh "${LINEAGE}: DONE ${DEVICE}"
   fi
done

if [ -x "${BUILDDIR}/notify.sh" ] ; then
   ${BUILDDIR}/notify.sh "${LINEAGE}: DONE ALL"
fi

echo "DONE"

