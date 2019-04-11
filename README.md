# nvidia-docker2上にtensorflowをビルドするためのファイル置き場

## 内容
　　Dockerfile: tensorflow-v1.12をインストールしたりビルドしたりする  
    collect_headers: build後に必要なヘッダーファイルを一箇所に収集するためのシェルスクリプト

## Dockerfileの実行前にすること
  * 自分の環境に合わせてDockerfileを変更する  

#### 変更箇所一覧
| 行数    | 変更内容                                              |
| ----- | ------------------------------------------------- |
| 23,24 | bazelのバージョンに合わせて変更                                |
| 33,34 | tensorflowのバージョンに合わせて変更                           |
| 38-58 | tensorflowの実行環境に合わせて変更(tensorflowのバージョンによっては増減アリ) <br>設定リストはgitでダウンロードしてくるtensorflowフォルダ内のconfigure.py内に記載されている |


