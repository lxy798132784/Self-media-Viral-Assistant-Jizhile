# 公众号爆文 API Apifox 文档

Source: https://s.apifox.cn/410674f9-f451-4b4f-957a-5f54f243bc83/352932520e0.md

> This local copy is used only for development and parameter coverage audits. Any credential-like samples must stay redacted.
>
> 此本地副本仅用于开发和参数覆盖审计。任何疑似凭据样例都必须保持脱敏。

# 公众号爆文api

## OpenAPI Specification

```yaml
openapi: 3.0.1
info:
  title: ''
  description: ''
  version: 1.0.0
paths:
  /fbmain/monitor/v3/hot_typical_search:
    post:
      summary: 公众号爆文api
      deprecated: false
      description: |-
        按条扣费   2分/条

        ### 返回结果
        | 字段 | 说明 |
        | --- | --- |
        | ['code'] | 状态码。0为成功 |
        | ['msg'] | 提示信息 |
        | ['note'] | 费用说明 |
        | ['cost'] | 花费 |
        | ['remain_money'] | 账户余额 |
        | ['total'] | 当前搜索结果数据总量 |
        | ['total_page'] | 当前搜索结果总页数 |
        | ['data'] | 数据 |
        | ['data'][i]['url'] | 链接 |
        | ['data'][i]['mp_nickname'] | 作者 |
        | ['data'][i]['title'] | 爆文标题 |
        | ['data'][i]['pub_time'] | 发布时间 |
        | ['data'][i]['wxid'] | 微信id |
        | ['data'][i]['hot'] | 微信爆值 |
        | ['data'][i]['read_num'] | 阅读数 |
        | ['data'][i]['zan_num'] | 点赞数 |
        | ['data'][i]['cover'] | 封面链接 |
        | ['data'][i]['avg'] | 平均阅读 |
        | ['data'][i]['category'] | 爆文分类 |
        | ['data'][i]['fans'] | 粉丝数 |
        | ['data'][i]['position'] | 发文位置，1是头条 |
        | ['data'][i]['is_original'] | 是否原创 |
        | ['data'][i]['publish_type'] | 爆文类型 |
      tags:
        - 公众号文章数据库搜索相关接口
      parameters: []
      requestBody:
        content:
          multipart/form-data:
            schema:
              type: object
              properties:
                key:
                  description: 极致了key
                  example: '{{key}}'
                  type: string
                keyword:
                  description: 关键词，为空则搜索全部
                  example: ''
                  type: string
                pub_type:
                  type: string
                  enum:
                    - '0'
                    - '5'
                    - '7'
                    - '8'
                    - '10'
                    - '11'
                  x-apifox-enum:
                    - value: '0'
                      name: 图文
                      description: ''
                    - value: '5'
                      name: 纯视频
                      description: ''
                    - value: '7'
                      name: 纯音乐
                      description: ''
                    - value: '8'
                      name: 纯图片
                      description: ''
                    - value: '10'
                      name: 纯文字
                      description: ''
                    - value: '11'
                      name: 转载文章
                      description: ''
                  description: 爆文类型，枚举值默认为0。0:图文 5:纯视频 7:纯音乐 8:纯图片 10:纯文字 11:转载文章
                  example: '0'
                category:
                  description: >-
                    爆文分类，枚举值默认为0。0：包含全部,1: "国际", 2: "体育", 3: "娱乐", 4: "社会", 5:
                    "财经",
                                    6: "时事", 7: "科技", 8: "情感", 9: "汽车", 10: "教育",
                                    11: "时尚", 12: "游戏", 13: "军事", 14: "旅游", 15: "美食",
                                    16: "文化", 17: "健康", 18: "搞笑", 19: "家居", 20: "动漫",
                                    21: "宠物", 22: "母婴", 23: "星座", 24: "历史", 25: "音乐",
                                    26: "未分类", 27: "综合", 28: "职场", 29: "三农", 30: "养老"
                  example: '0'
                  type: string
                page:
                  description: 翻页参数，默认为1表示第一页（2分/条）
                  example: '1'
                  type: string
                start_time:
                  description: 搜索爆文的开始日期，格式为2025-08-15
                  example: '2026-05-15'
                  type: string
                end_time:
                  description: 搜索爆文的截止日期，格式为2025-08-15
                  example: '2026-05-17'
                  type: string
              required:
                - key
                - pub_type
                - category
                - page
                - start_time
                - end_time
            examples: {}
      responses:
        '200':
          description: ''
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                    description: 状态码。0为成功
                  msg:
                    type: string
                    description: 提示信息
                  note:
                    type: string
                    description: 费用说明
                  cost:
                    type: number
                    description: 花费
                  remain_money:
                    type: number
                    description: 账户余额
                  total:
                    type: integer
                    description: 当前搜索结果数据总量
                  total_page:
                    type: integer
                    description: 当前搜索结果总页数
                  data:
                    type: array
                    items:
                      type: object
                      properties:
                        url:
                          type: string
                          description: 链接
                        mp_nickname:
                          type: string
                          description: 作者
                        title:
                          type: string
                          description: 爆文标题
                        pub_time:
                          type: string
                          description: 发布时间
                        wxid:
                          type: string
                          description: 微信id
                        hot:
                          type: number
                          description: 微信爆值
                        read_num:
                          type: integer
                          description: 阅读数
                        zan_num:
                          type: integer
                          description: 点赞数
                        cover:
                          type: string
                          description: 封面链接
                        avg:
                          type: integer
                          description: 平均阅读
                        category:
                          type: string
                          description: 爆文分类
                        fans:
                          type: integer
                          description: 粉丝数
                        position:
                          type: integer
                          description: 发文位置，1是头条
                        is_original:
                          type: string
                          description: 是否原创
                        publish_type:
                          type: string
                          description: 爆文类型
                      required:
                        - url
                        - mp_nickname
                        - title
                        - pub_time
                        - wxid
                        - hot
                        - read_num
                        - zan_num
                        - cover
                        - avg
                        - category
                        - fans
                        - position
                        - is_original
                        - publish_type
                      x-apifox-orders:
                        - url
                        - mp_nickname
                        - title
                        - pub_time
                        - wxid
                        - hot
                        - read_num
                        - zan_num
                        - cover
                        - avg
                        - category
                        - fans
                        - position
                        - is_original
                        - publish_type
                    description: 数据
                required:
                  - code
                  - msg
                  - note
                  - cost
                  - remain_money
                  - total
                  - total_page
                  - data
                x-apifox-orders:
                  - code
                  - msg
                  - note
                  - cost
                  - remain_money
                  - total
                  - total_page
                  - data
              example:
                code: 0
                msg: success
                note: 本接口单条数据为0.02，本次共获取20条数据，共消费0.4！注意，查询数据为空时默认算1条数据。
                cost: 0.4
                remain_money: 9797.39
                total: 28
                total_page: 2
                data:
                  - url: https://mp.weixin.qq.com/s/IBVfmDYFhHEhspLhR8QFtQ
                    mp_nickname: 乐活尚选
                    title: SHE成员被性侵！细节曝光，刺痛全网：他把手伸进裤子里…
                    pub_time: '2025-08-03 08:32:05'
                    wxid: gh_86ca4e5bb2a7
                    hot: 31.44
                    read_num: 3396
                    zan_num: 0
                    cover: >-
                      http://mmbiz.qpic.cn/sz_mmbiz_jpg/OvLunXgC3NQLoL9KNLib8RicweR6PpS6KfmiaC7131aXLicEUfUTUlZd3pXwuaNkz0ibBliaMTzFkAjomia8QeTLOeBqg/0?wx_fmt=jpeg
                    avg: 108
                    category: 国际
                    fans: 508082
                    position: 1
                    is_original: 非原创
                    publish_type: 转载
                  - url: https://mp.weixin.qq.com/s/gATFNXpK_Z2Y9gYMTAlBmw
                    mp_nickname: 全海南
                    title: 第10号台风“白鹿”生成！海南省气象部门提醒
                    pub_time: '2025-08-03 13:14:25'
                    wxid: gh_0c1847613c27
                    hot: 22.27
                    read_num: 12291
                    zan_num: 13
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/B1WOGgaYlfKPv6ee2icGzAOXibQKAnvvJBTAMqBlshhYgAn1LicRfkuWLCJ6iaGtVlEticricbR6N3OhkP9B90yLkt3w/0?wx_fmt=jpeg
                    avg: 552
                    category: 国际
                    fans: 104546
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/8jQZ4ERzlBuHZcJVPlPNpQ
                    mp_nickname: 墨子连山
                    title: 武汉大学毕业生求职被拒，诬陷“图书馆性骚扰”并非个例？说说我亲身经历过的3个武大女生事迹
                    pub_time: '2025-08-03 17:55:00'
                    wxid: gh_5881ef472bee
                    hot: 16.58
                    read_num: 10978
                    zan_num: 932
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/7Yggw9xdyhW0ZgpXADbnjJhKb62yRYrG0bCZRT27JaYdqhNFTMWPpdS3scwkk8J99a0O4lJnbRTKD3m8pia5HlA/0?wx_fmt=jpeg
                    avg: 662
                    category: 国际
                    fans: 184939
                    position: 1
                    is_original: 原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/wrRsjBSsEPLljwGxtfNKBA
                    mp_nickname: 考研阅读
                    title: |-
                      1、美国，最好的工作是律师
                      2、法国，最好的工作是教师
                      3、德国，最好的工作是工程师
                      4、日本，最好的职业是技术人员
                      5、新加坡，最好的职业是医生
                      6、英国，最好的职业是金融业
                      7、意大利，最好的职业是设计师
                      8、俄罗斯，最好的工职业是能源业

                      中国，最好的工作是?
                    pub_time: '2025-08-03 18:20:50'
                    wxid: gh_3ef47ade39b2
                    hot: 16.21
                    read_num: 4717
                    zan_num: 3
                    cover: ''
                    avg: 291
                    category: 国际
                    fans: 66559
                    position: 1
                    is_original: 非原创
                    publish_type: 文字
                  - url: https://mp.weixin.qq.com/s/ekLHAFejeMMj-UHn48sMNA
                    mp_nickname: 蒙古圈
                    title: 太突然！奥运冠军去世，年仅31岁
                    pub_time: '2025-08-03 14:52:15'
                    wxid: gh_a2808fe91256
                    hot: 14.91
                    read_num: 12901
                    zan_num: 10
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/5lRCKFWrtFAGwvD17jYO2ugMwCPWvKibZR4O0t1d6ft8DhVftjkrK7PlfoccRfcibybIMe49Y54IIvJfgoS5fb4g/0?wx_fmt=jpeg
                    avg: 865
                    category: 国际
                    fans: 711842
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/KKKUf2CLt4ks5be10Nq4PQ
                    mp_nickname: 艳姐喜运
                    title: 彻底倒向美国？公开向世界宣布制裁中国，关键时刻，中方火速发出警告
                    pub_time: '2025-08-03 15:33:00'
                    wxid: gh_e4e780d51812
                    hot: 14.66
                    read_num: 5161
                    zan_num: 56
                    cover: >-
                      http://mmbiz.qpic.cn/mmbiz_jpg/GYImsyXszGGWuLpLO2H198ZQV6iaNtqq5eCjH1d8DNFmyVUtfibBtCqMJR4X4LUNkFLCwtculwwXjo1hicftBn92Q/0?wx_fmt=jpeg
                    avg: 352
                    category: 国际
                    fans: 323703
                    position: 1
                    is_original: 非原创
                    publish_type: 视频
                  - url: https://mp.weixin.qq.com/s/ik_K-CUfSP-IBPXRMPFxqA
                    mp_nickname: 西河莲苑
                    title: 2025年6月全国助念通讯录来了！（收藏转发功德无量）
                    pub_time: '2025-08-03 07:50:08'
                    wxid: gh_edd4c6d19e80
                    hot: 13.97
                    read_num: 1034
                    zan_num: 44
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/b2FDcTZekPQuCib4Mq55dagEnMeR2xlNdhvCZibURrXkE08rW7uHfICwegJzAheKYTULNicpVMBaKIlI2IZ5whI1g/0?wx_fmt=jpeg
                    avg: 74
                    category: 国际
                    fans: 9491
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/ATZZriWOWAObXX-Ng4nnow
                    mp_nickname: 上海房地产观察
                    title: 世界主要都市房价走势
                    pub_time: '2025-08-03 08:00:00'
                    wxid: gh_3bca22c39987
                    hot: 11.09
                    read_num: 5322
                    zan_num: 13
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/j6j9qXJmOTwH7gICxnO0KalnfqgzVsMs5YM4T3KyndVxMWlMhshd1DQibnMghRKhggsBWSelGINaeeNTeehmqjw/0?wx_fmt=jpeg
                    avg: 480
                    category: 国际
                    fans: 305237
                    position: 1
                    is_original: 原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/2veOS80Qzt7FI8SgK7rr4g
                    mp_nickname: 寄情音乐
                    title: 中国决不帮“白眼狼”！邻国突传“噩耗”，700万人喊话中方求救，美西方盟友集体沉默
                    pub_time: '2025-08-03 16:33:00'
                    wxid: gh_4d1c4153b50f
                    hot: 11.04
                    read_num: 2583
                    zan_num: 15
                    cover: >-
                      http://mmbiz.qpic.cn/sz_mmbiz_jpg/x9YxqicsClmoGVnjR8IoSrGy424oDvrticicKTKq6ntP4PIQ7mReMYB6tFfsYaQsnIojlFgUGOMbic90hgRlGMvGVw/0?wx_fmt=jpeg
                    avg: 234
                    category: 国际
                    fans: 180059
                    position: 1
                    is_original: 非原创
                    publish_type: 视频
                  - url: https://mp.weixin.qq.com/s/SAtW1W_Xa6Ilxh1zCOGo0Q
                    mp_nickname: 最高裁判实务
                    title: 最高法：夫妻一方频繁转账给另一方，并不能就转款原因和款项性质作出合理解释的，应认定债务为夫妻共同债务
                    pub_time: '2025-08-03 11:40:00'
                    wxid: gh_574bdeed9c60
                    hot: 10.79
                    read_num: 13657
                    zan_num: 48
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/DwbUrJp7m87zuBVGGh5GiawFI7QzA5yjjRjELUc9cVC48Qo8ktVypIFkvt3aIpKUfIksK0xh6ibbvEL9xcz9juBw/0?wx_fmt=jpeg
                    avg: 1266
                    category: 国际
                    fans: 283998
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/2DumAUJPujDIQh_MChKgZg
                    mp_nickname: 中国计算机学会
                    title: 代码铸就青春勋章——IOI2025中国队四人尽数夺金
                    pub_time: '2025-08-03 10:03:09'
                    wxid: gh_2ac5be7fb69b
                    hot: 9.87
                    read_num: 8379
                    zan_num: 152
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/JP60Os9aSE7DQBEmMQUAD9hG988PU9R1QQHyK0WTgjoToO6LGxjzkKXrArqfakcx3rRpQgHWicgkbqviabibSicvaw/0?wx_fmt=jpeg
                    avg: 849
                    category: 国际
                    fans: 473375
                    position: 1
                    is_original: 原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/M0fTakTQyG4mvOXpttzG7w
                    mp_nickname: 廉洁沈阳
                    title: 市委常委会召开会议 霍步刚主持会议
                    pub_time: '2025-08-03 16:00:00'
                    wxid: gh_39bc31db9b5a
                    hot: 9.82
                    read_num: 2405
                    zan_num: 4
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/DtpFyM5CdTNRhpUkOepzT0DAhXbZ3JlicET6kCEvWrrr2sutBOibXtDzPcQnkoFQxNA7TXLQhBMYb64D9omiaxA7Q/0?wx_fmt=jpeg
                    avg: 245
                    category: 国际
                    fans: 74864
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/z3IwKgztVc4-YuzPTSmaWQ
                    mp_nickname: 她说她看
                    title: “干婚”现象越来越多，开始向全国蔓延，说出来原因扎心又现实
                    pub_time: '2025-08-03 12:00:00'
                    wxid: gh_f66b15aef4db
                    hot: 9.35
                    read_num: 6654
                    zan_num: 39
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/VOQVNSs2ZTphdjmKiciaU2XSYCNsJoZ9zROwF4NkIuZXs9JRkuI4iaUF4khHGOGRhmD4bdzsanZQnjjOEcJmzWlXQ/0?wx_fmt=jpeg
                    avg: 712
                    category: 国际
                    fans: 2189856
                    position: 1
                    is_original: 非原创
                    publish_type: 转载
                  - url: https://mp.weixin.qq.com/s/_ntlcTOdvft8Zn0LuMjK6w
                    mp_nickname: 新疆大学
                    title: 2025年新增批次海优，提供多重精准支持，新疆大学诚邀全球青年学者加盟！
                    pub_time: '2025-08-03 20:43:34'
                    wxid: gh_6e503997910f
                    hot: 9.31
                    read_num: 8907
                    zan_num: 55
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/PlqIdaGmRmBIJTUKJ52oCcoqdL3I9VmJK6amvnibRPIZaaYqPgxiaPJYFjuBFXn0ia388qjx7wBibOHwJqswQ9Mkibw/0?wx_fmt=jpeg
                    avg: 957
                    category: 国际
                    fans: 170547
                    position: 1
                    is_original: 原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/xGYA5zMYkoU9MAGSo4r0tA
                    mp_nickname: 定格深圳
                    title: 10号台风“白鹿”生成！深圳暴雨持续至……
                    pub_time: '2025-08-03 19:03:00'
                    wxid: gh_c2f207c8dfdf
                    hot: 8.78
                    read_num: 7882
                    zan_num: 15
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/ZAEMBySYuOPWR5jxWGO60BuRcph7zE6TmJ5gIJaC5kIKmY2HiaUL70DMSNuzzqFcb9x3xHn9b6XNsuicoPrykOTA/0?wx_fmt=jpeg
                    avg: 898
                    category: 国际
                    fans: 757348
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/7MWlu8V1lBqWNJlTCMx2Fg
                    mp_nickname: 信阳发布
                    title: 张宏伟到信阳高新区调研重点工业企业
                    pub_time: '2025-08-03 20:34:14'
                    wxid: gh_6e508dfbb2b7
                    hot: 7.54
                    read_num: 13308
                    zan_num: 58
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/MT4AqWAGDWvz3T66AJWhia3gsAZ1WD7l77IAKx5w06IibcVszN22iaDskvv8v8gqRl3VfYvMu7m1prdzZy7lGESYw/0?wx_fmt=jpeg
                    avg: 1764
                    category: 国际
                    fans: 147169
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/DWspCEqlmgjlV5Apt4-yBw
                    mp_nickname: 轮胎国际视角
                    title: 山东某轮胎工厂，法人遭限高
                    pub_time: '2025-08-03 14:47:04'
                    wxid: gh_c92ae3fbd7d2
                    hot: 7.19
                    read_num: 2352
                    zan_num: 7
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/Rewyeoyy6IQ8icaibN0IjXH7ibAjBaN7O6nBP5Q0yW40HA2yR2M5HA6l5EXKZVfrrRZFl8drUjCSLRK2ibKB58QDmQ/0?wx_fmt=jpeg
                    avg: 327
                    category: 国际
                    fans: 40616
                    position: 2
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/J4Vte4tYFrr-Z2JqNL7BXQ
                    mp_nickname: MBA经营学
                    title: 马航事件终于大白天下，11年过去了，联合国机构终于裁定：俄罗斯负责....
                    pub_time: '2025-08-03 06:31:00'
                    wxid: gh_75cdf6c138b9
                    hot: 7.19
                    read_num: 3158
                    zan_num: 3
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/DqAALia4qwJhqrYd9LzvOfE8L80zIjzl0EJCodyKGkNbrsgIXD9JOm9ib9mOoCUeleuia1LabQybjQ792RuNichibwg/0?wx_fmt=jpeg
                    avg: 439
                    category: 国际
                    fans: 169987
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/GxVdDSNhJ1sRbu7nvSIB3A
                    mp_nickname: 祺印说信安
                    title: 外交部：中国将继续采取必要措施维护自身的网络安全
                    pub_time: '2025-08-03 06:02:54'
                    wxid: gh_9c4aaf253255
                    hot: 7.16
                    read_num: 544
                    zan_num: 5
                    cover: >-
                      https://mmbiz.qpic.cn/sz_mmbiz_jpg/rTibWNx9ARWk2eg9DqUOTLLURpp71tLPTa9WXVPWPfSDiaBkBKibb7ozKrgzlqSPMlYKPjrrjYrWM33yx0gywkIOw/0?wx_fmt=jpeg
                    avg: 76
                    category: 国际
                    fans: 10884
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
                  - url: https://mp.weixin.qq.com/s/PSZ_RXprUmd17iDBtxbb5A
                    mp_nickname: 商密君
                    title: 美国对中国实施网络攻击 外交部：中方将采取必要措施
                    pub_time: '2025-08-03 19:33:00'
                    wxid: gh_a02c9d0e1990
                    hot: 7.15
                    read_num: 529
                    zan_num: 2
                    cover: >-
                      https://mmbiz.qpic.cn/mmbiz_jpg/1HyKzSU2XXMHMPnKWaRuGDt384MWUBhDamvEnVbianwnqsvqiapv6icicWiaX9xSYCrwY8ZFibn6DLUY2AiajSFtjOK6g/0?wx_fmt=jpeg
                    avg: 74
                    category: 国际
                    fans: 36388
                    position: 1
                    is_original: 非原创
                    publish_type: 图文
          headers: {}
          x-apifox-name: 成功
      security: []
      x-apifox-folder: 公众号文章数据库搜索相关接口
      x-apifox-status: released
      x-run-in-apifox: https://app.apifox.com/web/project/4919579/apis/api-352932520-run
components:
  schemas: {}
  securitySchemes: {}
servers:
  - url: https://www.dajiala.com
    description: 正式环境
security: []

```
