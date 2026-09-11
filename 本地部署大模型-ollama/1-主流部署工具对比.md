# 本地大模型部署指南

## 一、主流部署工具对比
| 工具 | 特点 | 适用场景 |
| ---- | ---- | ---- |
| Ollama | 一键安装、命令行/REST API、模型库丰富 | 个人用户、快速上手 |
| LM Studio | 图形界面、支持多种格式、内置聊天 | 非技术用户、可视化操作 |
| llama.cpp | 纯C++、极致性能优化、支持量化 | 开发者、边缘设备、低显存 |
| vLLM | 高吞吐、PagedAttention、OpenAI兼容API | 生产环境、API服务 |
| Text Generation Inference (TGI) | HuggingFace出品、多GPU支持 | 企业级部署 |
| xinference | 国产开源、支持多种模型类型 | 中文用户、多模型管理 |

**硬件要求参考**

| 模型规模 | 显存需求（FP16） | 显存需求（4-bit量化） | 推荐配置 |
| ---- | ---- | ---- | ---- |
| 7B | 14 GB | 4 GB | RTX 3060 12GB / M1 Pro 16GB |
| 13B | 26 GB | 8 GB | RTX 3090 24GB / M2 Max 32GB |
| 70B | 140 GB | 40 GB | 2×A100 80GB / 4×RTX 4090 |
| 满血版（如DeepSeek-R1 671B） | 1342 GB | 350 GB | 8×H100 或 多机集群 |

> 💡 CPU+内存方案：llama.cpp 支持纯CPU运行，32GB内存可跑7B量化模型，128GB可跑70B量化模型。
