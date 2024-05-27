# BootStrap

## 1.组要内容

## 2.BootStrap的安装和使用

### 2.1 BootStrap 介绍

### 2.2 BootStrap 特点

1.简介、直观、强悍的前端开发框架，html、css、javacript 工具集，让web开发更速、简单。

2.基于html5、css3。

3.自定义JQuery插件，完整的类库

### 2.3 下载和使用

官方文档： https://getbootstrap.com/

中文网： 	https://www.bootcss.com/

1. 下载：https://v3.bootcss.com/getting-started/#download

   下载生产环境的文件比较小

2. 下载完成后

 	拷贝dist/css 中的 bootstrap.min.css到项目的 css 中

​	拷贝dist/js 中的 bootstrap 中的 bootstrap.min.js 到项目的 js 中

3. 下载jquery.js

JQUERY下载：官方[下载地址1](https://jquery.com/download/)            [下载地址2](https://www.jq22.com/jquery-info122#google_vignette)

4. 在HTML 中模板为：

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
	<!-- 使用X-UA-Compatible来设置IE浏览器兼容模式 最新渲染模式！ -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="./css/bootstrap.min.css">

    <!-- HTML5 shim 和 Respond.js 是为了让 IE8 支持 HTML5 元素和媒体查询（media queries）功能 -->
    <!-- 警告：通过 file:// 协议（就是直接将 html 页面拖拽到浏览器中）访问页面时 Respond.js 不起作用 -->
    <!--[if lt IE 9]>
      <script src="https://fastly.jsdelivr.net/npm/html5shiv@3.7.3/dist/html5shiv.min.js"></script>
      <script src="https://fastly.jsdelivr.net/npm/respond.js@1.4.2/dest/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
    <h1>你好，世界！</h1>

    <!-- jQuery (Bootstrap 的所有 JavaScript 插件都依赖 jQuery，所以必须放在前边) -->
    <script src="./js/jquery-3.4.1.min.js"></script>
    <!-- 加载 Bootstrap 的所有 JavaScript 插件。你也可以根据需要只加载单个插件。 -->
    <script src="./js/bootstrap.min.js"></script>
  </body>
</html>
```



说明：



## 3. 栅格网格系统

#### 	3.2、容器布局

​		**container** `固定宽度  边上有留白`

​		**container-fluid** `完整宽度`

#### 3.2	栅格网络系统

​		通过定义容器大小，平分12分（最常见），在调整内外间距，最后结合媒体查询，就制作出了最强大的响应式网格系统。

|           |          |          |          |          |          |          |          |          |          |          |          |
| --------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- | -------- |
| .col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 | col-md-1 |

​	注意:	网格系统必须使用到css



​	container、 row 、xs(xsmall pones),	sm(small tablets),	md(middle desktops),	lg(larger desktops)

即：超小屏(自动)	小屏(750px)	中屏(970px)和大屏(1170px)

​	数据行(.row)必须包含在容器(.container)	中，以便为其赋予合适的对其方式和内间距(padding)。

​	在行(.row)中可以添加列(.column),只有列	(column)	才可以作为容(.row)的直接子元素，但例数之和不能超过平分的总和，比如12。如果大于12，则自动换行到下一行。

```html
		<div class="container">
			<div class="row">
				<div class="col-md-4">4列</div>
				<div class="col-md-8">8列</div>
			</div>
		</div>
```

注意:	col-md-4   md即上面的参数



### 栅格参数

通过下表可以详细查看 Bootstrap 的栅格系统是如何在多种屏幕设备上工作的。

|                       | 超小屏幕 手机 (<768px)     | 小屏幕 平板 (≥768px)                                | 中等屏幕 桌面显示器 (≥992px) | 大屏幕 大桌面显示器 (≥1200px) |
| :-------------------- | :------------------------- | :-------------------------------------------------- | :--------------------------- | :---------------------------- |
| 栅格系统行为          | 总是水平排列               | 开始是堆叠在一起的，当大于这些阈值时将变为水平排列C |                              |                               |
| `.container` 最大宽度 | None （自动）              | 750px                                               | 970px                        | 1170px                        |
| 类前缀                | `.col-xs-`                 | `.col-sm-`                                          | `.col-md-`                   | `.col-lg-`                    |
| 列（column）数        | 12                         |                                                     |                              |                               |
| 最大列（column）宽    | 自动                       | ~62px                                               | ~81px                        | ~97px                         |
| 槽（gutter）宽        | 30px （每列左右均有 15px） |                                                     |                              |                               |
| 可嵌套                | 是                         |                                                     |                              |                               |
| 偏移（Offsets）       | 是                         |                                                     |                              |                               |
| 列排序                | 是                         |                                                     |                              |                               |





### 列偏移

使用 `.col-md-offset-*` 类可以将列向右侧偏移。这些类实际是通过使用 `*` 选择器为当前元素增加了左侧的边距（margin）。例如，`.col-md-offset-4` 类将 `.col-md-4` 元素向右侧偏移了4个列（column）的宽度。

```html
<div class="row">
  <div class="col-md-4">.col-md-4</div>
  <div class="col-md-4 col-md-offset-4">.col-md-4 .col-md-offset-4</div>
</div>
<div class="row">
  <div class="col-md-3 col-md-offset-3">.col-md-3 .col-md-offset-3</div>
  <div class="col-md-3 col-md-offset-3">.col-md-3 .col-md-offset-3</div>
</div>
<div class="row">
  <div class="col-md-6 col-md-offset-3">.col-md-6 .col-md-offset-3</div>
</div>
```





### 列排序

通过使用 `.col-md-push-*` 和 `.col-md-pull-*` 类就可以很容易的改变列（column）的顺序。

```html
<div class="row">
  <div class="col-md-9 col-md-push-3">.col-md-9 .col-md-push-3</div>
  <div class="col-md-3 col-md-pull-9">.col-md-3 .col-md-pull-9</div>
</div>
```



###  嵌套列

为了使用内置的栅格系统将内容再次嵌套，可以通过添加一个新的 `.row` 元素和一系列 `.col-sm-*` 元素到已经存在的 `.col-sm-*` 元素内。被嵌套的行（row）所包含的列（column）的个数不能超过12（其实，没有要求你必须占满12列）。

```html
<div class="row">
  <div class="col-sm-9">
    Level 1: .col-sm-9
    <div class="row">
      <div class="col-xs-8 col-sm-6">
        Level 2: .col-xs-8 .col-sm-6
      </div>
      <div class="col-xs-4 col-sm-6">
        Level 2: .col-xs-4 .col-sm-6
      </div>
    </div>
  </div>
</div>
```





## 4.常用样式

### 4.1.	排版

#### 4.1.2	标题

​		HTML 中的所有标题标签，`<h1>` 到 `<h6>` 均可使用。另外，还提供了 `.h1` 到 `.h6` 类，为的是给内联（inline）属性的文本赋予标题的样式。

​		在标题内还可以包含 `<small>` 标签或赋予 `.small` 类的元素，可以用来标记副标题。

```html
<h1>h1. Bootstrap heading <small>Secondary text</small></h1>
<div class="h1">Bootstrap标题1<span class="small">副标题</span></div>
```

#### 4.1.3.段落

​		通过添加 `.lead` 类可以让段落突出显示。

```html
<p class="lead">...</p>
```

#### 4.1.4 强调

```html
<p class="text-muted">提示，浅灰</p>
<p class="text-primary">主要-蓝色</p>
<p class="text-success">成功-浅绿色</p>
<p class="text-info">信息-浅蓝色</p>
<p class="text-warning">警告-黄色</p>
<p class="text-danger">危险-褐色</p>
```

#### 4.1.5.对齐

```html
<p class="text-left">左对齐</p>
<p class="text-center">居中</p>
<p class="text-right">右对齐</p>
<p class="text-justify">设定文本对齐,段落中超出屏幕部分文字自动换行</p>
<p class="text-nowrap">段落中超出屏幕部分不换行</p>
```

#### 4.1.6.列表

```html
<ul>  <li>	无序列表...</li></ul>
<ol>  <li>	有序列表...</li></ol>
<ul class="list-unstyled">  <li>无样式列表(去点列表)...</li></ul>
<ul class="list-inline">  <li>内联列表(水平方向)...</li></ul>
<dl class="dl-horizontal">  <dt>水平排列列表</dt>  <dd>超过160px显示...</dd></dl>
```

#### 4.1.7.代码

​	1.通过 `<code></code>` 标签包裹内联样式的代码片段。

​	2.多行代码可以使用 `<pre></pre>` 标签。为了正确的展示代码，注意将尖括号做转义处理。

​		样式：pre-scrollable(height,max-height高度固定为 340px,超过存在滚动条)

​	3.通过 `<kbd></kdb> `标签标记用户通过键盘输入的内容。

##### 4.1.7.1.单行内联代码

只能显示1行

```html
<code>this is a simple code</code>
```

##### 4.1.7.2.用户输入

```html
<kbd><kbd>ctrl</kbd> + <kbd>,</kbd></kbd>
```

##### 4.1.7.3. 代码块

代码保持原格式展现

```html
<pre>
public String execute(RequestInfo request) {
  
}
</pre>
```







#### 4.1.8.表格

###### 4.1.8.1.表格样式

​	**基础样式**

​		为任意 `<table>` 标签添加 `.table` 类可以为其赋予基本的样式 — 少量的内补（padding）和水平方向的分隔线。	

```html
<table class="table">
  ...
</table>
```

​	**附加样式**

​			1.条纹状表格： `.table-striped` 类可以给 `<tbody>` 之内的每一行增加斑马条纹样式。

​			2.带边框的表格：`.table-bordered`	类为表格和其中的每个单元格增加边框

​			3.鼠标悬停： `.table-hover` 类可以让 `<tbody>` 中的每一行对鼠标悬停状态作出响应。

​			4. 紧缩表格： `.table-condensed` 类可以让表格更加紧凑，单元格中的内补（padding）均会减半。

###### 4.1.8.2.tr、td、th

​		通过这些状态类可以为行或单元格设置颜色。

| Class      | 描述                                 |
| :--------- | :----------------------------------- |
| `.active`  | 鼠标悬停在行或单元格上时所设置的颜色 |
| `.success` | 标识成功或积极的动作                 |
| `.info`    | 标识普通的提示信息或动作             |
| `.warning` | 标识警告或需要用户注意               |
| `.danger`  | 标识危险或潜在的带来负面影响的动作   |

```html
<table class="table table-striped table-bordered table-hover">
			<tr class="active">
				<th>java</th>
				<th>数据库</th>
				<th>JavaScript</th>
			</tr>
			<tr class="danger">
				<td>one</td>
				<td>two</td>
				<td>cc</td>
			</tr>
			<tr class="success">
				<td>three</td>
				<td>four</td>
				<td>vv</td>
			</tr>
		</table>
```



### 4.2.表单

#### 4.2.1.表单控件

##### 4.2.1.1.输入框 text

`form-control`

```html
<input type="text" class="form-control" id="" value="" />
```

##### 4.2.1.2.下拉选择框 select

```html
<select class="form-control" multiple="multiple">
					<option value="">请选择城市</option>
					<option value="">上海</option>
					<option value="">北京</option>
				</select>
```

##### 4.2.1.3.文本域 textarea

```html
<textarea class="form-control	"></textarea>
```

##### 4.2.1.4.复选框 checkbox

```html
<!-- 垂直 -->
<div>
	<div id="" class="checkbox"><label> <input type="checkbox" name="hobby" id="" value="" />唱歌</label></div>
	<div id="" class="checkbox"><label> <input type="checkbox" name="hobby" id="" value="" />跳舞</label></div>
</div>
```

​	**水平显示**

```html
<!-- 水平显示 -->
<div id="">
	<label class="checkbox-inline"> <input type="checkbox" name="hobby" id="" value="" />唱歌</label>
	<label class="checkbox-inline"> <input type="checkbox" name="hobby" id="" value="" />跳舞</label>
</div>
```

##### 4.2.1.5.单选框 radio

<!-- 垂直显示 -->

```html

<div id="" class="radio">
	<label><input type="radio" name="sex" id="" value="" />男</label>
</div>
<div id="" class="radio">
	<label><input type="radio" name="sex" id="" value="" />女</label>
</div>
```

<!-- 水平显示 -->

```html

<div id="">
	<label class="radio-inline"><input type="radio" name="sex" id="" value="" />男</label>
	<label class="radio-inline"><input type="radio" name="sex" id="" value="" />女</label>
</div>
```

##### 4.2.1.6. 按钮

**可作为按钮使用的标签或元素**为 `<a>`、`<button>` 或 `<input>` 元素添加按钮类（button class）即可使用 Bootstrap 提供的样式。

​	基础样式:	btn

```html
<button type="button" class="btn btn-default">（默认样式）Default</button>
```

​	附加样式:	btn btn-primary btn-success btn-info btn-warning btn-danger btn-link

```html
<button type="button" class="btn btn-primary">（首选项）Primary</button>
<button type="button" class="btn btn-success">（成功）Success</button>
<button type="button" class="btn btn-info">（一般信息）Info</button>
<button type="button" class="btn btn-warning">（警告）Warning</button>
<button type="button" class="btn btn-danger">（危险）Danger</button>
<button type="button" class="btn btn-link">（链接）Link</button>
```

​	多标签支持:	使用`<a>` `<div>`

```html
<a class="btn btn-default" href="#" role="button">Link</a>
<span id=""class="btn btn-success">span标签按钮</span>
<div id=""class="btn btn-warning">div标签按钮</div>
```



​	按钮大小:	btn-lg  btn-sm btn-xs

```html
<button type="button" class="btn btn-default btn-lg">大按钮</button>
<button type="button" class="btn btn-default btn-sm">小按钮</button>
<button type="button" class="btn btn-default btn-xs">超小尺寸</button>
```



#### 4.2.2.表单布局

##### 4.2.2.1.水平表单



### 4.3.缩略图



### 4.4.面板