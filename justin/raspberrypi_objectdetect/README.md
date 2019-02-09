# Rasberry Pi Tensorflow Object Detector 


## Demoed on 2.7.19

### What this does:

Builds a Tensorflow-based object detection system, running on Raspbian OS, and using the Raspberry Pi camera or a USB camera.  

### Notes

* you need to compile protobuf and cv2 from source and install them, so no point in a requirements.txt  

* avg ~1.2 FPS
*  40-50% memory utilization
* Built on Raspberry Pi 3 Model B+
* To select between ssdlite_mobilenet_v2_coco_2018_05_09, ssd_mobilenet_v1_ppn_shared_box_predictor_300x300_coco14_sync_2018_07_03 or ssd_resnet50_v1_fpn_shared_box_predictor_640x640_coco14_sync_2018_07_03 just comment/uncomment the corresponding MODEL_NAME lines.

