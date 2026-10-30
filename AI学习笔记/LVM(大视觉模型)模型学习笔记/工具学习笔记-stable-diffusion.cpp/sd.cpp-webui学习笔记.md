## 大模型
### sd-1.5
#### 模型量化：
sd-cli.exe -M convert -m models\checkpoints\sd-1-5_pruned_emaonly.safetensors -o models\checkpoints\sd-1-5-q8_0.gguf --type q8_0 -v

采样参数：
--sampling-method dpm++2m --scheduler karras --steps 24 --cfg-scale 7

### sdxl-turbo-unet（webui不支持）

#### 模型下载
https://hf-mirror.com/stabilityai/sdxl-turbo

采样参数：
--sampling-method dpm++2mv2 --scheduler karras --steps 26 --cfg-scale 7

#### 模型量化：
sd-cli.exe -M convert -m models\unet\sdxl_turbo.safetensors -o models\unet\sdxl-turbo-q4_k.gguf --type q4_K -v

#### 运行参数
sd-cli.exe -M img_gen --prompt-file outputs\pprompts\pprompt_72.txt --negative-prompt-file outputs\nprompts\prompt_72.txt --sampling-method euler --scheduler flux2 --steps 3 -W 1024 -H 1024 --cfg-scale 1 -s -1 -o outputs\txt2img\xl_01.png --diffusion-model models\unet\sd_xl_turbo_1.0_fp16.safetensors --vae models\vae\vae.safetensors --clip_g models\text_encoders\clip_g_xl.safetensors --clip_l models\text_encoders\clip_l_xl.safetensors --embd-dir models\embeddings --scheduler sgm_uniform --backend cpu --mmap

sd-cli.exe -M img_gen --prompt-file outputs\pprompts\pprompt_76.txt --negative-prompt-file outputs\nprompts\nprompt_76.txt --sampling-method euler --scheduler flux2 --steps 4 -W 800 -H 600 --cfg-scale 1 -s -1 -o outputs\txt2img\46.png --diffusion-model models\unet\sdxl_turbo.safetensors --vae models\vae\sdxl_vae_fp16.safetensors --clip_g models\text_encoders\clip_g-sdxl.safetensors --clip_l models\text_encoders\clip_l-sdxl.safetensors --embd-dir models\embeddings --scheduler sgm_uniform --backend cpu --mmap

sd-cli.exe -M img_gen --prompt-file outputs\pprompts\pprompt_78.txt --negative-prompt-file outputs\nprompts\nprompt_78.txt --sampling-method euler --scheduler flux2 --steps 4 -W 800 -H 600 --cfg-scale 1 -s -1 -o outputs\txt2img\46.png --diffusion-model models\unet\sdxl_turbo.safetensors --vae models\vae\vae_sdxl.safetensors --clip_g models\text_encoders\clip_g-sdxl.safetensors --clip_l models\text_encoders\clip_l-sdxl.safetensors --embd-dir models\embeddings --scheduler sgm_uniform --backend te=cpu,vae=cpu --vae-tile-overlap 0.5 --vae-tile-size 64x64 --offload-to-cpu --vae-tiling --mmap

sd-cli.exe -M img_gen --prompt-file outputs\pprompts\pprompt_79.txt --negative-prompt-file outputs\nprompts\nprompt_79.txt --sampling-method euler --scheduler flux2 --steps 4 -W 800 -H 600 --cfg-scale 1 -s -1 -o outputs\txt2img\46.png --diffusion-model models\unet\sdxl-turbo-q4_k.gguf --vae models\vae\vae_sdxl.safetensors --clip_g models\text_encoders\clip_g-sdxl.safetensors --clip_l models\text_encoders\clip_l-sdxl.safetensors --embd-dir models\embeddings --scheduler sgm_uniform --backend te=cpu,vae=cpu --offload-to-cpu --mmap


### sdxl-turbo-checkpoint
#### 模型下载
https://hf-mirror.com/stabilityai/sdxl-turbo/tree/main

#### 模型量化：
sd-cli.exe -M convert -m models\checkpoints\sd_xl_turbo_1.0_fp16.safetensors -o models\checkpoints\sd_xl_turbo_1.0-q8_0.gguf --type q8_0 -v

采样参数：
- Sampling method：`euler` （官方推荐，原生配对）
- Scheduler：`sgm_uniform`
- Steps：**1 ~ 4**（超过 4 步效果就会开始崩坏）
- CFG scale：**固定 = 1**（SDXL-Turbo 训练不带 CFG，CFG>1 基本都会乱）

### flux-2-klein-4b

运行参数：
1. 示例
.\bin\Release\sd-cli.exe --diffusion-model  ..\models\diffusion_models\flux-2-klein-4b.safetensors --vae ..\models\vae\flux2_ae.safetensors  --llm ..\models\text_encoders\qwen_3_4b.safetensors -p "a lovely cat" --cfg-scale 1.0 --steps 4 -v --offload-to-cpu --diffusion-fa

.\bin\Release\sd-cli.exe --diffusion-model  ..\models\diffusion_models\flux-2-klein-4b.safetensors --vae ..\models\vae\flux2_ae.safetensors  --llm ..\models\text_encoders\qwen_3_4b.safetensors -r .\kontext_input.png -p "change 'flux.cpp' to 'klein.cpp'" --cfg-scale 1.0 --sampling-method euler --scheduler flux2 -v --diffusion-fa --offload-to-cpu --steps 4

2. 客户端参数
2.1 文生图
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 1280 -H 720 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu -p "一名东方现代少女，清秀侧脸，坐在湖边木质长椅上，微微抬头，双眼轻闭，嘴角浅笑，清风吹动长发飞扬，湖面微澜，远处柔和水色天光，侧面中近景，电影感柔和光影，清新写实，细腻肤质，空气通透，高细节" -n "五官崩坏，肢体畸形，色彩断层，过曝，死黑，文字水印" -o outputs\img2img\t2i_msn.png 

sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 720 -H 1280 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu -p "迪迦奥特曼，银色巨型英雄，红色与紫色身体条纹，头部水晶状冠饰，胸前蓝色彩色计时器，双眼发光，正面直立站立，双臂自然下垂，全身正面视图，平视正面视角，特摄动画风格，高画质，细节清晰，锐利边缘" -n "畸变，模糊，噪点，文字，水印，低质量，多余肢体，比例失调，肢体畸形，面部崩坏，多余手指" -o outputs\img2img\t2i_djatm.png 


sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 720 -H 1280 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu --strength 0.75 -p "电商商品展示图，一只不锈钢真空保温杯居中摆放，杯身印有传统腾龙生肖图案，纹样古典精致，杯盖与杯底金属质感，干净纯色背景，柔和棚拍柔光，商业产品摄影，高清细节，广告词`生肖随行，温暖有型`清晰呈现于画面留白处" -n "形变，结构错误，多余部件，反光杂乱，阴影脏，水印" -o outputs\img2img\t2i_bwb2.png 

2.2 图生图
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 720 -H 1280 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu --strength 0.75 -p "严格保留原图中的少女人物形象与外观特征（面容、发型、穿搭气质），仅替换场景与动作，将其置于开心逛街购物的情境中，保持人物身份一致，繁华商业步行街，两侧店铺橱窗流光，暖色街灯与霓虹，少女漫步或驻足，手中提着精致购物袋，笑容灿烂，神情愉悦，微风轻动发丝，生活化现代写实，自然肤质，高细节，氛围感" -n "五官扭曲，多余手指，肢体畸形，比例失调，塑料皮肤，畸变，模糊，噪点，文字，水印，低质量" -r asserts\OIP-C.jfif -o outputs\img2img\i2i_sngj.png

sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 720 -H 1280 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu --strength 0.75 -p "严格保留参考图1中小男孩的头部与脸部不变，仅将身体服饰替换为迪迦奥特曼铠甲，调整姿态为双脚并拢笔直站立，背景替换为纯白色；银色与红紫色奥特曼铠甲，胸前蓝色彩色计时器，全身正面平视，均匀柔光，写实照片风格，高画质，细节清晰，边缘自然" -n "畸变，模糊，噪点，文字，水印，低质量，头部改变，面部扭曲，肢体畸形，多余手指，铠甲未还原，背景非纯白，比例失调" -r asserts\zrh.png -r asserts\djatm.png -o outputs\img2img\i2i_zrh_djatm.png 

sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 6 -W 720 -H 1280 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu --strength 0.75 -p "严格保留参考图1中小男孩的头部与脸部不变，仅将身体服饰替换为迪迦奥特曼铠甲，调整姿态为双脚并拢笔直站立，背景替换为纯白色；银色与红紫色奥特曼铠甲，胸前蓝色彩色计时器，全身正面平视，均匀柔光，写实照片风格，高画质，细节清晰，边缘自然" -n "畸变，模糊，噪点，文字，水印，低质量，头部改变，面部扭曲，肢体畸形，比例失调" -r asserts\zrh-header.png -o outputs\img2img\i2i_zrh-header.png 

P：严格保留参考图1中男孩的脸部与奥特曼铠甲外观、身份不变，仅将其放入城市战斗场景，调整为进攻对峙姿态（男孩朝右前方45度、相机位于其左前方的3/4侧身视角），并生成宇宙怪兽艾雷王与正在被破坏的城市背景；艾雷王为黄褐色带黑色条纹的爬行类巨大怪兽，头生尖角，长尾，发光双眼，周身电弧；倒塌建筑、碎裂街道、烟尘，戏剧化战斗光影，真人实景特摄风格，电影感，高画质，细节清晰
N：畸变，模糊，噪点，文字，水印，低质量，铠甲改变，面部扭曲，肢体畸形，多余手指，怪兽畸形，城市穿帮，比例失调，塑料感，画面杂乱
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 1280 -H 720 --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu --strength 0.75 -p "严格保留参考图1中身穿奥特曼铠甲的亚洲小男孩的外观与身份不变，与宇宙怪兽艾雷王形成对峙以阻止其破坏城市，进攻形态攻击姿态，小男孩左侧45度角镜头；艾雷王为紫色鳞甲长尾怪兽，头顶发光角，凶恶姿态；城市废墟战场背景，建筑破损，真人实景特摄战斗场面，电影级光影，戏剧性打光，高画质，细节丰富，氛围紧张" -n "畸变，模糊，噪点，文字，水印，低质量，小男孩外观改变，肢体畸形，多余手指，艾雷王形态错误，比例失调，画面杂乱，穿帮" -r asserts\i2i_zrh.png -o outputs\img2img\i2i_zrh-vs-alw.png

2.3 三视图
1）文生三视图
P：宇宙怪兽艾雷王，蓝色身体带黑色纵向条纹，头顶两根触角，背脊锯齿状背鳍，长尾末端发光球体，标准三视图设定表，同一角色横向并排三栏，正面、侧面、背面，各栏独立不重叠，白色细分割线分隔，中性站姿，四肢自然展开，长尾完整入镜不遮挡，全身完整入镜，纯白背景，均匀柔光，光影一致，平视镜头，湿润鳞状皮肤质感，发光尾球呈半透明荧光，写实特摄怪兽风格，高清，轮廓清晰，构图干净NNDN：肢体畸形，五官扭曲，身体比例错误，多余肢体，画面互相融合重叠，不同个体，多余个体，动态姿势，透视混乱，文字，水印，logo
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 1024 -H 800‬ --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu -p "Space Monster Eleking, blue body with black vertical stripes, two antennae on the head, serrated dorsal fins along the spine, glowing sphere at the tail tip, character turnaround sheet, three horizontal panels, front view, side view, back view, independent panels not overlapping, thin white divider lines, neutral standing pose, limbs spread naturally, long tail fully in frame without occlusion, full body in frame, pure white background, soft even lighting, consistent lighting across panels, eye-level camera, wet scaly leathery skin texture, translucent glowing tail orb, realistic tokusatsu monster style, high definition, clean composition" -n "deformed limbs, distorted facial features, wrong body proportions, extra limbs, merged panels, different creatures, extra creatures, dynamic pose, broken perspective, text, watermark, logo" -o outputs\img2img\3v_alw.png 


2）真人三视图
- P：严格以第1张参考图的主体形象为准，保留关键特征，同一主体，标准 T-pose 站姿，双臂自然平举，正面视角、侧面视角、背面视角横向并排，独立分栏，白色分割线分隔，画面互不重叠，纯白背景，均匀柔光，全场光影一致，全身完整入镜，平视视角，标准人像焦段，自然肤质与真实服饰材质，写实摄影风格，高清，轮廓清晰，角色资产设定图，构图干净
- N：肢体畸形，五官扭曲，手指错乱，画面互相融合重叠，不同人物，动态姿势，透视混乱，文字，水印，logo
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 1024 -H 800‬ --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu -r asserts\zrh.png --strength 0.75 -p "以第1张参考图中的小男孩为唯一主体，其余人物与物体不出现，五官、发型与身材比例与参考图保持一致，标准三视图设定表，同一角色横向并排三栏，正面、侧面、背面，各栏独立不重叠，白色细分割线分隔，T-pose自然站立，双臂平举，全身完整入镜，纯白背景，均匀柔光，全场光影一致，平视镜头，真实肤质与布料衣物纹理，写实摄影，高清，轮廓清晰，构图干净" -n "肢体畸形，五官扭曲，手指错乱，画面互相融合重叠，不同人物，多余人物，多个主体，动态姿势，透视混乱，文字，水印，logo" -o outputs\img2img\3v_zrh.png

3）动漫三视图
-- P：严格按第1张参考图绘制，外形、配色和特征完全保持不变；画面主体是二次元动漫少女，发型、发色、瞳色和服装与参考图一致，标准站立正面姿态，三视图设定表，正面、侧面、背面三栏横向独立排布，栏间留白清晰不重叠，浅灰色纯色背景，均匀柔光，全场光影一致，全身完整入镜，平视视角，皮肤与服饰材质真实细腻，赛璐璐平涂画风，高清，轮廓清晰，角色资产设定图，构图干净。
-- N：角色长相不一致，分栏画面融合，肢体崩坏，多余肢体，文字水印，杂乱背景
sd-cli.exe -M img_gen --sampling-method euler --scheduler flux2 --steps 4 -W 1024 -H 800‬ --cfg-scale 1 -s -1 --diffusion-model models\unet\flux-2-klein-4b-Q4_0.gguf --vae models\vae\vae.safetensors --llm models\text_encoders\Qwen3-4B-Q4_K_M.gguf --embd-dir models\embeddings --backend cpu --params-backend *=cpu --offload-to-cpu -r asserts\dmsn.png --strength 0.75 -p "strictly follow reference image 1, keep exact appearance, features and color matching reference image 1, anime girl character, hairstyle and outfit consistent with reference, standard standing front pose, three-view character sheet, front side back in three separate panels, horizontal layout with clean gaps, no overlap between panels, light gray plain background, even soft lighting, consistent lighting across all views, full body in frame, eye-level camera, detailed skin and fabric texture, cel-shaded flat color anime style, high resolution, clean sharp outlines, character asset reference sheet, clean composition." -n "inconsistent character appearance, merged panels, broken limbs, extra limbs, text watermark, cluttered background" -o outputs\img2img\3v_dmsn.png 

2.4 线稿图
黑白线稿三视图，横向并排，同一个人物/物体，正面、侧面、背面，所有角度结构一致，比例准确，线条清晰，纯白背景，无彩色，无阴影，无材质，无背景，无文字，无水印，正交视图，设定稿风格。

## 模型量化
sd-cli.exe -M convert -m models\unet\sdxl_turbo.safetensors -o models\unet\sdxl-turbo-q4_k.gguf --type q4_K -v


## 测试指令
masterpiece, best quality, 1girl, red hair, big eyes, beautiful face, detailed face, walking on the street, city sidewalk, trees and cars in background, natural lighting, sharp focus


<lora:sd-1-5_lora_weights:1> A pretty girl with red hair and big eyes is walking on the street.

<lora:sd-1-5_lora_weights:0.8> masterpiece, best quality, 1girl, red hair, big eyes, symmetrical face, beautiful facial features, detailed eyes, walking on city street, full body, natural pose, outdoor, sunny day, sharp focus, coherent body structure

(worst quality, low quality:1.4), blurry, ugly, deformed, disfigured, bad anatomy, extra limbs, missing limbs, floating limbs, mutated hands, bad hands, extra fingers, missing fingers, deformed face, asymmetrical face, distorted eyes, cross-eyed, mutated, ugly face, watermark, text, signature, oversaturated, noisy, grainy


##  tup fang
sd-cli.exe -M upscale --init-img C:\Users\guosen\AppData\Local\Temp\gradio\1a44f0f73c92e9c94d56f2d1cc0c54b5e024bda9deec749bb725ed447a39adc3\30.png --upscale-model models\upscale_models\RealESRGAN_x4plus.pth -W 800 -H 608 --upscale-repeats 1 --upscale-tile-size 128 -o outputs\upscale\29.png