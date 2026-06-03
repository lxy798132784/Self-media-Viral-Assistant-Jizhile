# export_id转object_id

## OpenAPI Specification

```yaml
openapi: 3.0.1
info:
  title: ''
  description: ''
  version: 1.0.0
paths:
  /fbmain/monitor/v3/wxvideo:
    post:
      summary: export_id转object_id
      deprecated: false
      description: |+
        | 字段 |说明  |
        | --- | --- |
        code = 0  |调用成功
        105      |请求类型不存在
        50000    |服务器内部错误


        | 字段 |说明  |
        | --- | --- |
        object_id       |该视频的唯一id
        nickname        |视频号名字
        v2_name         |视频号唯一id

      tags:
        - 视频号接口
      parameters: []
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                type:
                  type: string
                  description: type=7  固定值
                export_id:
                  type: string
                  description: >-
                    视频唯一id 例如
                    ：export/UzFfAgtgekIEAQAAAAAAnNgTS8uKMAAAAAstQy6ubaLX4KHWvLEZgBPEnqJsIzprE_mJzNPgMIoCiBgqw9m_Usm6Iq8QgtRc
                key:
                  type: string
                  description: 极致了key （0.05/次）
                verifycode:
                  type: string
                  description: 如果设置了需要填写
              x-apifox-orders:
                - type
                - export_id
                - key
                - verifycode
              required:
                - type
                - export_id
                - key
                - verifycode
            example:
              type: 7
              export_id: >-
                export/UzFfAgtgekIEAQAAAAAAnNgTS8uKMAAAAAstQy6ubaLX4KHWvLEZgBPEnqJsIzprE_mJzNPgMIoCiBgqw9m_Usm6Iq8QgtRc
              key: '{{key}}'
              verifycode: ''
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
                    description: 状态码
                  object_id:
                    type: string
                    description: 视频的 唯一id
                  nickname:
                    type: string
                    description: 视频号名字
                  v2_name:
                    type: string
                    description: 视频号v2name
                  cost:
                    type: number
                    description: 消费
                  remain_money:
                    type: number
                    description: 余额
                required:
                  - code
                  - object_id
                  - nickname
                  - v2_name
                  - cost
                  - remain_money
                x-apifox-orders:
                  - code
                  - object_id
                  - nickname
                  - v2_name
                  - cost
                  - remain_money
          headers: {}
          x-apifox-name: 成功
      security: []
      x-apifox-folder: 视频号接口
      x-apifox-status: released
      x-run-in-apifox: https://app.apifox.com/web/project/4919579/apis/api-302964463-run
components:
  schemas: {}
  securitySchemes: {}
servers:
  - url: https://www.dajiala.com
    description: 正式环境
security: []

```
