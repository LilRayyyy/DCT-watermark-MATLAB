% 读取原始图像并转换为灰度图像
img = imread('heibaixiaogou.png'); % 请确保此图像文件存在于当前目录
img_gray = rgb2gray(img);

% 对原始图像进行二维离散余弦变换（DCT）
img_dct = dct2(double(img_gray));

% 产生随机水印序列，并按绝对值降序排序
n = 100; % 水印序列长度
watermark = randn(1, n);
[~, sorted_indices] = sort(abs(watermark), 'descend');
sorted_watermark = watermark(sorted_indices);

% 选择DCT系数中的低频部分，取前k个最大的系数
k = 100; % 嵌入水印的系数个数
[~, dct_sorted_indices] = sort(abs(img_dct(:)), 'descend');
low_freq_indices = dct_sorted_indices(1:k);

% 嵌入水印序列到选定的DCT系数中
alpha = 0.1; % 嵌入强度
for i = 1:k
    img_dct(low_freq_indices(i)) = img_dct(low_freq_indices(i)) + alpha * sorted_watermark(i);
end

% 生成嵌入水印后的图像
watermarked_img = uint8(idct2(img_dct));
imwrite(watermarked_img, 'aab.png'); % 保存嵌入水印后的图像

% 提取水印序列
img_dct_extracted = dct2(double(watermarked_img));
extracted_watermark = zeros(1, k);
for i = 1:k
    extracted_watermark(i) = (img_dct_extracted(low_freq_indices(i)) - img_dct(low_freq_indices(i))) / alpha;
end

% 相关性计算
n_test = 100; % 测试序列的个数
test_sequences = [extracted_watermark; randn(n_test-1, n)];
correlation_matrix = corrcoef([sorted_watermark; test_sequences]);

% 显示原始图像和嵌入水印后的图像在一个窗口中
figure;
subplot(1, 2, 1);
imshow(img_gray);
title('原始图像');

subplot(1, 2, 2);
imshow(watermarked_img);
title('嵌入水印后的图像');

% 显示嵌入水印后的图像在一个单独的窗口中
figure;
imshow(watermarked_img);
title('嵌入水印后的图像 (单独显示)');

% 显示原始水印图像在一个单独的窗口中
figure;
watermark_image = imresize(reshape(sorted_watermark, [10, 10]), [50, 50]); % 假设原水印重排后为10x10矩阵
imshow(mat2gray(watermark_image));
title('原始水印图像');

% 缩放水印图像
scaled_watermark = imresize(reshape(sorted_watermark, [10, 10]), [50, 50]); % 假设原水印重排后为10x10矩阵

% 显示缩放水印图像和提取的水印在一个窗口中
figure;
subplot(1, 2, 1);
imshow(mat2gray(scaled_watermark));
title('缩放后的水印图像');

subplot(1, 2, 2);
extracted_watermark_image = imresize(reshape(extracted_watermark, [10, 10]), [50, 50]); % 假设提取的水印重排后为10x10矩阵
imshow(mat2gray(extracted_watermark_image));
title('提取的水印图像');
