# Google mapに必要なcsvデータの作成
## 背景
土地勘の無い場所で住所と紙の地図だけで掲示板の場所にたどり着けれるとは思えない。そこでGoogle mapにピンを打ちナビが使えればいいのだがその為に住所をcsvにする必要がある。  
選管からは紙で住所が示されるがデータでは何故か渡してくれない。かと言ってベタ打ちをする気力もない。GoogleレンズでOCRも試みたが成形のほうが大変そうなのでこれも断念。  
残るは住所データとベタ打ちの丁目番地号を対応させて結合させることだ。そのためのツールを作ってみた。バグがあり操作中に落ちるとそれまでにした作業がパーになるが何度か操作し慣れてくれば最後までいけるかも。
## 動作確認環境
Windows10 / VSCode / Ruby ruby 2.7.2p137
## 作業手順
必要な都道府県のcsvファイルを[住所.jp](http://jusyo.jp/csv/new.php)からダウンロードし展開する。  
掲示板一覧表から何丁目何番地何号の部分のみを打ち込み、選挙区市町村名.datとして保存する。(別名でも可)  
 丁目はtと打ち込む。1t2-3は1丁目2-3と展開される。番地などが何も無い場合は改行ではなく必ず**空白を一つ**入力する。  
```ruby go_nhk.rb 住所.jp 選挙区市町村名　(選挙区市町村名.dat)```  

|コマンド|内容|
|:-----------|:---|  
|enter　　　　　|次のの町村名を表示&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  
|s |選挙区市町村名.dsvのファイル名で保存して終了|  
p |次の町村名7行を表示  
ls |編集されたものの番号を表示　ls 20のようにすると20番以降の10行を表示  
d 20|のようにすると番号が20のものを削除します。重複して入力してしまった場合削除して再入力します。とりあえず放置して後でエディターで修正してもいいでしょう。  
t or 1/|上から一つ目に移動します  
/ |位置を一つ上げます  
// |位置を二つ上げます  
/// |位置を三つ上げます  
2/ |上から二つ目に移動します  
3/ |上から三つ目に移動します  
4/ |上から四つ目に移動します  
a,i,u.. .wa |地名の最初の一文字をローマ字で検索して位置を変更例:中屋敷を検索する場合ナカヤシキの最初の一文字ナのローマ字naと入力。半濁点、濁点は無い。  |
数字 |その位置の地名のものを登録する。複数ある場合は空白で区切る。 <br> 連続する場合に23-30は 23 24 25 26 27 28 29 30と同等  

選挙区市町村名.dsvはcsvなのでこのままでも使えるが  
```ruby go_nhk.rb 選挙区市町村名.dsv```  
とすることで町を区切りにして名称にした選挙区市町村名.csvを生成する。  
地区名を表示の後に* がついたものは既に選択されていた事を示す(重複防止のため)

## BUG
読みに対応する地区が無い場合落ち  
dsvの住所に町以降が無いと落ちる  
ローマ字の読みに対応が無い場合elseで数値扱いとなり落ちる
