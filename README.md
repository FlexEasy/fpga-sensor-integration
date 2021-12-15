# fpga-sensor-integration

## Project Description
 - 본 프로젝트는 Xilinx라는 하드웨어를 이용하여 하드웨어에 부착할 수 있는 CMOS 이미지 센서, 온도 감지 센서및 열 감지 센서 등을 Xilinx와 연결하여 비동기 방식으로, 복수의 아날로그 데이터 값을 읽어낼 수 있도록 HDL을 이용하여 데이터 파이프 라인을 설계합니다. 여기에 사용되는 프로토콜은 I2C프로토콜로 여러 센서로부터 동시에 데이터 값을 받을 수 있도록 병렬로 프로토콜을 설정하여 여러 개의 센서로부터 데이터의 혼선이 없이 각각 독립적으로 데이터를 받아낼 수 있습니다. 
 - 이는 오늘 날에 쓰이는 다양한 센서들의 아날로그 값을 컴퓨터로 받아 디지털 값으로 변환하여 우리가 원하는 온도, 압력, 영상 등의 결과물로 변환하는 데에 가장 기본이 되는 부분으로, 데이터 파이프라인의 설계가 끝난 후에는 Python을 이용하여 데이터를 요청 수집 조작 및 센서의 제어를 할 수 있도록 하며 이는 Lab7MS3.py 에 있습니다. 전체적인 파이프라인은 top_copy.v(기존 source 폴더 내에 있는 파일을 편의를 위하여 별도로 복사함)에 기술되어 있습니다.

## Reference
[FPGA and Sensor Integration Project Report.docx](https://github.com/FlexEasy/fpga-sensor-integration/files/7720791/FPGA.and.Sensor.Integration.Project.Report.docx)

