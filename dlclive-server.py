import socket
import cv2
import numpy as np
import asyncio
import websockets
import json
import logging
import deeplabcut_live  # 导入DeepLabCut Live库，用于实时关键点检测

# 配置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# UDP接收配置
UDP_IP = "0.0.0.0"  # 监听所有网络接口
UDP_PORT = 8888     # 与手机端UdpSenderService中设置的端口一致

# WebSocket配置
WS_HOST = "localhost"
WS_PORT = 8765

# 创建UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))
logging.info(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")

# 初始化DeepLabCut模型
dlc_model = deeplabcut_live.DLCInference(
    model_path='path/to/your/model.pth',  # 替换为你的模型路径（DeepLabCut训练导出的PyTorch模型）
    config_path='path/to/your/config.yaml'  # 替换为你的配置文件路径（包含关键点名称、图像尺寸等配置）
)

# DeepLabCut推理函数
async def dlc_inference(image):
    # 使用DeepLabCut进行推理
    keypoints = dlc_model.inference(image)
    return keypoints

# WebSocket处理函数
async def websocket_handler(websocket, path):
    logging.info("WebSocket connection established")
    try:
        while True:
            # 接收UDP数据
            data, addr = sock.recvfrom(65507)  # 最大UDP包大小
            logging.info(f"Received image from {addr}")

            # 解码JPEG图像
            nparr = np.frombuffer(data, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if image is None:
                logging.error("Failed to decode image")
                continue

            # 调用DeepLabCut推理
            keypoints = await dlc_inference(image)

            # 发送结果回手机端
            result = {
                "keypoints": keypoints,
                "timestamp": asyncio.get_event_loop().time()
            }
            await websocket.send(json.dumps(result))
            logging.info("Sent inference results to client")

    except websockets.exceptions.ConnectionClosed:
        logging.info("WebSocket connection closed")
    except Exception as e:
        logging.error(f"Error: {e}")

# 启动WebSocket服务器
async def main():
    async with websockets.serve(websocket_handler, WS_HOST, WS_PORT):
        logging.info(f"WebSocket server started on ws://{WS_HOST}:{WS_PORT}")
        await asyncio.Future()  # 保持服务器运行

if __name__ == "__main__":
    asyncio.run(main())
