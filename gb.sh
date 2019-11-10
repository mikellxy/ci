#!/bin/bash

current=`date "+%Y-%m-%d %H:%M:%S"`
timeStamp=`date -d "$current" +%s`
#将current转换为时间戳，精确到毫秒
currentTimeStamp=$((timeStamp*1000+`date "+%N"`/1000000))
echo $currentTimeStamp

echo set $APP_NAME $APP_IMAGE_TAG_PROD\_$currentTimeStamp | redis-cli -h $REDIS_HOST -p 6379