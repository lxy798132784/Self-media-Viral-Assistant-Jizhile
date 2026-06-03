# 极致了 API 本地归档总览

> 来源：`/home/pi/Downloads/极致了LLM.txt`；已下载 Apifox Markdown/OpenAPI 文档到 `raw/`；结构化索引见 `api-index.json`。

- 文档总数：48
- 分类数：8
- 通用接入判断：文档均为 OpenAPI 3.0 Markdown，主体接口多为 `POST`，路径集中在 `/fbmain/monitor/v3/...`。
- 重要限制：多处提示 QPS 不高于 2 次/秒、请求频繁需等待 2~5 秒；新项目必须内置限速、重试和缓存。
- 密钥策略：本文档只归纳接口，不保存任何真实 API Key；开发时从环境变量读取。

## 分类目录

### 视频号接口（15 个）
- **搜一搜 实时搜全部 (视频号视频) (可排序)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：currentPage, mode, offset, items, word, items, key, value；本地：`01_视频号接口_搜一搜_实时搜全部_视频号视频_可排序__454008225e0.md`
- **搜一搜 实时搜视频类目 (视频号账号)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：currentPage, mode, offset, items, word, items, key, value；本地：`02_视频号接口_搜一搜_实时搜视频类目_视频号账号__454541896e0.md`
- **搜一搜 实时搜视频类目 (视频号视频)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：keyword, BusinessType, Sub_search_type, currentPage, offset, cookies_buffer, key, verifycode；本地：`03_视频号接口_搜一搜_实时搜视频类目_视频号视频__454541709e0.md`
- **获取单个视频号作品列表（链接不可下载 可翻页）**：`POST /fbmain/monitor/v3/wxvideo`；实时；必填/核心参数：待看文档；本地：`04_视频号接口_获取单个视频号作品列表_链接不可下载_可翻页__209503843e0.md`
- **获取视频号直播回放记录**：`POST /fbmain/monitor/v3/wxvideo`；实时；必填/核心参数：object, id, nickname, username, object_desc, description, media, url；本地：`05_视频号接口_获取视频号直播回放记录_357729356e0.md`
- **获取指定视频号ID**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：key, type, keywords；本地：`06_视频号接口_获取指定视频号ID_226936157e0.md`
- **关键词搜索视频号**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：verifycode, type, keywords；本地：`07_视频号接口_关键词搜索视频号_214452163e0.md`
- **获取视频号可下载链接**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：object_id, key, type, fav_count, like_count, forward_count, comment_count, download_url；本地：`08_视频号接口_获取视频号可下载链接_209532597e0.md`
- **export_id转object_id**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：export_id, key, verifycode, object_id, nickname, v2_name, cost, remain_money；本地：`09_视频号接口_export_id转object_id_302964463e0.md`
- **通过公众号原始id获取绑定的视频号**：`POST /fbmain/monitor/v3/history_by_ghid`；必填/核心参数：key, get_finder, user_name, nickname, ServiceType, NickName, HeadImgUrl, BaseInfo；本地：`10_视频号接口_通过公众号原始id获取绑定的视频号_368651318e0.md`
- **获取视频号视频点赞数、评论数等互动信息**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：key, type, count_info, comment_count, like_count, forward_count, fav_count, version_data；本地：`11_视频号接口_获取视频号视频点赞数_评论数等互动信息_389255941e0.md`
- **获取视频号视频一级评论**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：key, type, last_buffer, comment_info, username, nickname, content, comment_id；本地：`12_视频号接口_获取视频号视频一级评论_389257187e0.md`
- **获取视频号视频二级评论**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：key, type, last_buffer, comment_info, username, nickname, content, comment_id；本地：`13_视频号接口_获取视频号视频二级评论_446364600e0.md`
- **通过视频链接获取视频号基础信息**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：key, type, verifycode, msg, data, object_id, object_nonce_id, nickname；本地：`14_视频号接口_通过视频链接获取视频号基础信息_447634016e0.md`
- **获取视频号标题**：`POST /fbmain/monitor/v3/wxvideo`；必填/核心参数：nickname, username, title, media_type, cost, remain_money；本地：`15_视频号接口_获取视频号标题_460453061e0.md`

### 公众号当天和历史文章链接获取（3 个）
- **通过公众号名称/微信Id/链接获取公众号当天发文情况**：`POST /fbmain/monitor/v3/post_condition`；实时；必填/核心参数：url, key, msg, data, position, url, post_time, post_time_str；本地：`16_公众号当天和历史文章链接获取_通过公众号名称_微信Id_链接获取公众号当天发文情况_199748761e0.md`
- **通过公众号名称/微信Id/链接获取公众号历史发文列表**：`POST /fbmain/monitor/v3/post_history`；实时；必填/核心参数：url, key, msg, data, position, url, post_time, post_time_str；本地：`17_公众号当天和历史文章链接获取_通过公众号名称_微信Id_链接获取公众号历史发文列表_199746415e0.md`
- **通过公众号原始id获取历史列表（针对无法搜索账号）**：`POST /fbmain/monitor/v3/history_by_ghid`；实时；必填/核心参数：key, ServiceType, NickName, HeadImgUrl, BaseInfo, MsgId, MsgType, DateTime；本地：`18_公众号当天和历史文章链接获取_通过公众号原始id获取历史列表_针对无法搜索账号__368137945e0.md`

### 公众号文章内容和互动数据等（9 个）
- **获取文章阅读、点赞、在看**：`POST /fbmain/monitor/v3/read_zan`；实时；必填/核心参数：key, msg, data, read, zan, looking, msg, content_text；本地：`19_公众号文章内容和互动数据等_获取文章阅读_点赞_在看_199750063e0.md`
- **获取文章阅读、点赞、在看、转发、收藏、评论 Pro**：`POST /fbmain/monitor/v3/read_zan_pro`；实时；必填/核心参数：key, msg, data, read, zan, looking, share_num, collect_num；本地：`20_公众号文章内容和互动数据等_获取文章阅读_点赞_在看_转发_收藏_评论_Pro_204205487e0.md`
- **获取文章详情(纯文本,富文本,不带html文章格式)**：`GET /fbmain/monitor/v3/article_detail`；必填/核心参数：cost_money, remain_money, title, mp_head_img, source_url, signature, author, desc；本地：`21_公众号文章内容和互动数据等_获取文章详情_纯文本_富文本_不带html文章格式__220474677e0.md`
- **获取文章正文 HTML**：`POST /fbmain/monitor/v3/article_html`；必填/核心参数：key, verifycode, msk, cost_money, remain_money, data, title, biz；本地：`22_公众号文章内容和互动数据等_获取文章正文_HTML_199736592e0.md`
- **获取文章详情Pro**：`POST /fbmain/monitor/v3/article_detail`；必填/核心参数：key, verifycode, cost_money, remain_money, title, article_url, mp_head_img, cover_url；本地：`23_公众号文章内容和互动数据等_获取文章详情Pro_199752498e0.md`
- **获取公众号文章评论Pro**：`POST /fbmain/monitor/v3/article_comment2`；实时；必填/核心参数：buffer, key, verifycode, msg, data, content, logo_url, nick_name；本地：`24_公众号文章内容和互动数据等_获取公众号文章评论Pro_199758598e0.md`
- **获取公众号文章二级评论**：`POST /fbmain/monitor/v3/article_sub_comment`；实时；必填/核心参数：content_id, key, verifycode, msg, data, content, logo_url, nick_name；本地：`25_公众号文章内容和互动数据等_获取公众号文章二级评论_445204557e0.md`
- **获取公众号文章阅读、点赞、名字，文章标题和URL等信息**：`POST /fbmain/monitor/v3/article_info`；必填/核心参数：key, verifycode, msg, cost, remain_money, data, url, msg；本地：`26_公众号文章内容和互动数据等_获取公众号文章阅读_点赞_名字_文章标题和URL等信息_199766293e0.md`
- **获取文章详情(视频可下载)**：`POST /fbmain/monitor/v3/article_detail_video`；必填/核心参数：cost_money, remain_money, title, mp_head_img, source_url, signature, author, desc；本地：`27_公众号文章内容和互动数据等_获取文章详情_视频可下载__402258301e0.md`

### 公众号文章数据库搜索相关接口（3 个）
- **关键词 搜索 微信文章（数据库）**：`POST /fbmain/monitor/v3/kw_search`；实时；必填/核心参数：sort_type, mode, period, page, key, any_kw, ex_kw, msg；本地：`28_公众号文章数据库搜索相关接口_关键词_搜索_微信文章_数据库__199754666e0.md`
- **分词 搜索 微信文章2（数据库）**：`POST /fbmain/monitor/v3/kw_search`；实时；必填/核心参数：sort_type, mode, period, page, key, any_kw, ex_kw, type；本地：`29_公众号文章数据库搜索相关接口_分词_搜索_微信文章2_数据库__345662373e0.md`
- **公众号爆文api**：`POST /fbmain/monitor/v3/hot_typical_search`；必填/核心参数：msg, note, cost, remain_money, total, total_page, data, url；本地：`30_公众号文章数据库搜索相关接口_公众号爆文api_352932520e0.md`

### 公众号文章实时搜一搜相关接口（2 个）
- **搜一搜 实时搜全部 (公众号文章)(可排序)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：keyword, search_type, publish_time_type, sort_type, currentPage, offset, cookies_buffer, key；本地：`31_公众号文章实时搜一搜相关接口_搜一搜_实时搜全部_公众号文章_可排序__454005291e0.md`
- **搜一搜 实时搜文章类目 (公众号文章)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：keyword, BusinessType, Sub_search_type, currentPage, offset, cookies_buffer, key, verifycode；本地：`32_公众号文章实时搜一搜相关接口_搜一搜_实时搜文章类目_公众号文章__454005293e0.md`

### 其他微信实时搜一搜相关接口（4 个）
- **搜一搜 实时搜搜索推荐词**：`POST /fbmain/monitor/v3/web_search_sug`；实时；必填/核心参数：key, BusinessType, data, sug_words；本地：`33_其他微信实时搜一搜相关接口_搜一搜_实时搜搜索推荐词_463516678e0.md`
- **搜一搜 实时搜账号类目(小程序账号)**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：currentPage, mode, offset, items, word, items, key, value；本地：`34_其他微信实时搜一搜相关接口_搜一搜_实时搜账号类目_小程序账号__456895413e0.md`
- **搜一搜 实时搜微信指数类目**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：mode, BusinessType, sub_search_type, key, verifycode, word, key, value；本地：`35_其他微信实时搜一搜相关接口_搜一搜_实时搜微信指数类目_456895415e0.md`
- **搜一搜 实时搜汇总版（包含mode1和mode2）**：`POST /fbmain/monitor/v3/web_search`；实时；必填/核心参数：currentPage, mode, offset, cost_money, remain_money, data；本地：`36_其他微信实时搜一搜相关接口_搜一搜_实时搜汇总版_包含mode1和mode2__454005170e0.md`

### 公众号账号搜索和账号基本信息（8 个）
- **获取公众号原创文章数**：`POST /fbmain/monitor/v3/original_article_count`；实时；必填/核心参数：key, UserName, ServiceType, NickName, HeadImgUrl, OriginalContentStr；本地：`37_公众号账号搜索和账号基本信息_获取公众号原创文章数_463107539e0.md`
- **获取公众号主体信息**：`POST /fbmain/monitor/v3/principal_info`；必填/核心参数：url, wxid, key, verifycode, msg, data, auth_3rd_list, desc；本地：`38_公众号账号搜索和账号基本信息_获取公众号主体信息_199757379e0.md`
- **获取公众号头像、账号类型、公众号简介等基础信息**：`POST /fbmain/monitor/v3/avatar_type`；实时；必填/核心参数：key, verifycode, msg, data, name, biz, wxid, type；本地：`39_公众号账号搜索和账号基本信息_获取公众号头像_账号类型_公众号简介等基础信息_199760628e0.md`
- **获取公众号的预估活跃粉丝、头条平均阅读、头条平均点赞、周发文量、最新发文时间、极致了指数**：`POST /fbmain/monitor/v3/Keyverifycode`；实时；必填/核心参数：name, key, verifycode, msg, data, name, ghid, wxid；本地：`40_公众号账号搜索和账号基本信息_获取公众号的预估活跃粉丝_头条平均阅读_头条平均点赞_周发文量_最新发文时间_极致了指数_199761469e0.md`
- **主体名下公众号搜索**：`POST /fbmain/monitor/v3/owner_search_mp`；必填/核心参数：key, verifycode, msg, data, area, auth_3rd_list, desc, gender；本地：`41_公众号账号搜索和账号基本信息_主体名下公众号搜索_212866367e0.md`
- **根据关键字查询公众号**：`POST /fbmain/monitor/v3/wx_account/search`；实时；必填/核心参数：page, size, key, verifycode, mode, msg, data, name；本地：`42_公众号账号搜索和账号基本信息_根据关键字查询公众号_199762047e0.md`
- **搜一搜 搜公众号**：`POST /fbmain/monitor/v3/web_search`；必填/核心参数：keyword, BusinessType, Sub_search_type, currentPage, cookies_buffer, key, verifycode, offset；本地：`43_公众号账号搜索和账号基本信息_搜一搜_搜公众号_317874204e0.md`
- **获取指定类别公众号内的日榜周榜月榜**：`POST /fbmain/rank/v1/get_account_type_rank`；必填/核心参数：page, industry_id, key, verifycode, error_code, data, data, rank；本地：`44_公众号账号搜索和账号基本信息_获取指定类别公众号内的日榜周榜月榜_199769682e0.md`

### 未分类（4 个）
- **公众号文章链接长短互转**：`POST /fbmain/monitor/v3/link/short2long`；必填/核心参数：key, verifycode, cost_money, short_url, long_url；本地：`45_未分类_公众号文章链接长短互转_199751449e0.md`
- **搜狗临时链接转永久链接**：`POST /fbmain/monitor/v3/sougou_link`；必填/核心参数：verifycode, msg, data, ori_link, permanent_link；本地：`46_未分类_搜狗临时链接转永久链接_199771856e0.md`
- **获取api余额**：`POST /fbmain/monitor/v3/get_remain_money`；必填/核心参数：verifycode, remain_money, yesterday_money, request_time；本地：`47_未分类_获取api余额_247333202e0.md`
- **搜狗搜索文章链接转永久链接**：`POST /fbmain/monitor/v3/sougou_dn9a`；必填/核心参数：msg, data, ori_link, permanent_link；本地：`48_未分类_搜狗搜索文章链接转永久链接_390256751e0.md`
