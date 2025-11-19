## 插件介绍

##### Code Runner  

可以直接点击右上角运行前端代码  如`javascript`

**使用方法：**

1. 使用快捷键Ctrl+Alt+N
2. 或按F1键，然后选择/键入运行代码，
3. 或者右键单击文本编辑器，然后单击编辑器上下文菜单中的运行代码
4. 或者单击编辑器标题菜单中的运行代码按钮
5. 或者单击文件资源管理器上下文菜单中的“运行代码”按钮

**停止方法：**

1. 使用快捷键Ctrl+Alt+M
2. 或按F1键，然后选择/键入停止代码运行
3. 或者单击编辑器标题菜单中的停止代码运行按钮
4. 或者右键单击输出通道，然后在关联菜单中单击停止代码运行

##### open in browser

use `Alt + B` shortcut to open current *html* file in default browser, or `Shift + Alt + B` to choose a browser. you could also right click just like the picture:

使用Alt+B快捷键在默认浏览器中打开当前html文件，或使用Shift+Alt+B选择浏览器。您也可以右键单击，如图所示：



## 插件安装

Material Theme    主题
Prettier - Code formatter		自动格式化      设置  搜索SAVE   在Editor On Save 勾选
Bracket Pair Colorization Tog	给括号变色
Auto Rename Tag			修改前半部分标签后面跟这便
Auto Close Tag
Live Server				本地开启HTTP Server 并监听Ctrl + S 页面自动刷新
HTML CSS Support
Open in Browser
HTML Snippets
JavaScript (ES6) code snippets
ESLint
Vetur
Code Runner



###### **`VScode 配置用户代码片段`**

```vue
{
    "生成vue模板": {
        "prefix": "vue",
        "body": [
            "<!-- $1 -->",
            "<template>",
            "<div class='$2'>$5</div>",
            "</template>",
            "",
            "<script>",
            "//这里可以导入其他文件（比如：组件，工具js，第三方插件js，json文件，图片文件等等）",
            "//例如：import 《组件名称》 from '《组件路径》';",
            "",
            "export default {",
            "//import引入的组件需要注入到对象中才能使用",
            "components: {},",
            "data() {",
            "//这里存放数据",
            "return {",
            "",
            "};",
            "},",
            "//监听属性 类似于data概念",
            "computed: {},",
            "//监控data中的数据变化",
            "watch: {},",
            "//方法集合",
            "methods: {",
            "",
            "},",
            "//生命周期 - 创建完成（可以访问当前this实例）",
            "created() {",
            "",
            "},",
            "//生命周期 - 挂载完成（可以访问DOM元素）",
            "mounted() {",
            "",
            "},",
            "beforeCreate() {}, //生命周期 - 创建之前",
            "beforeMount() {}, //生命周期 - 挂载之前",
            "beforeUpdate() {}, //生命周期 - 更新之前",
            "updated() {}, //生命周期 - 更新之后",
            "beforeDestroy() {}, //生命周期 - 销毁之前",
            "destroyed() {}, //生命周期 - 销毁完成",
            "activated() {}, //如果页面有keep-alive缓存功能，这个函数会触发",
            "}",
            "</script>",
            "<style scoped>",
            "$4",
            "</style>"
        ],
        "description": "Log output to console"
    },
    "http-get请求": {
        "prefix": "httpget",
        "body": [
            "this.\\$http({",
            "url: this.\\$http.adornUrl(''),",
            "method: 'get',",
            "params: this.\\$http.adornParams({})",
            "}).then(({ data }) => {",
            "})"
        ],
        "description": "httpGET请求"
    },
    "http-post请求": {
        "prefix": "httppost",
        "body": [
            "this.\\$http({",
            "url: this.\\$http.adornUrl(''),",
            "method: 'post',",
            "data: this.\\$http.adornData(data, false)",
            "}).then(({ data }) => { });"
        ],
        "description": "httpPOST请求"
    }
}
```

