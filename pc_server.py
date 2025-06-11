import socket
import cv2
import numpy as np
import asyncio
import websockets
import json
import logging

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

# 模拟Bonsai推理函数（实际需替换为Bonsai SDK调用）
async def bonsai_inference(image):
    # 这里替换为实际的Bonsai推理逻辑
    # 示例：返回随机关键点数据
    keypoints = np.random.rand(10, 2).tolist()  # 假设10个关键点
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

            # 调用Bonsai推理
            keypoints = await bonsai_inference(image)

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