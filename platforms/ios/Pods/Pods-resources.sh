#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
install_resource "XMPPFramework/Extensions/Roster/CoreDataStorage/XMPPRoster.xcdatamodel"
install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld"
install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld/XMPPRoom.xcdatamodel"
install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld"
install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld/XMPPRoomHybrid.xcdatamodel"
install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld"
install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld/XMPPvCard.xcdatamodel"
install_resource "XMPPFramework/Extensions/XEP-0115/CoreDataStorage/XMPPCapabilities.xcdatamodel"
install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld"
install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld/XMPPMessageArchiving.xcdatamodel"
install_resource "XMPPFramework/Xcode/ServerlessDemo/ServerlessDemo.xcdatamodel"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  DEVICE=`if [ "${TARGETED_DEVICE_FAMILY}" -eq 1 ]; then echo "iphone"; else echo "ipad"; fi`
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" --target-device "${DEVICE}" --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
fi
