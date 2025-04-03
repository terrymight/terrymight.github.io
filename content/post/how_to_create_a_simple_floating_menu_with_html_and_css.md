---
title: "How to create a simple floating menu with HTML and CSS"
date: "2023-03-01T09:50:46+02:00"
tags: ["HTML", "CSS"]
categories: ["HTML"]
authors: ["Tejiri Mayone"]
---

{{< figure src="/post/images/how_to_create_a_simple_floating_menu_with_html_and_css.jpeg" caption="floating menu with HTML and CSS" >}}

<!--more-->

## Introduction

Creating a floating menu in HTML and CSS can be a great way to add navigation to your website without taking up too much space. In this blog post, we'll go over how to create a simple floating menu using HTML and CSS.

### HTML

First, we'll create the HTML structure for our floating menu. We'll use an unordered list to hold the links, and a div to hold the entire menu.

```go-html-template
<div class="floating-menu">
  <ul>
    <li><a href="#">Home</a></li>
    <li><a href="#">About</a></li>
    <li><a href="#">Contact</a></li>
  </ul>
</div>

```

### CSS

Next, we'll use CSS to style our menu and make it float. We'll start by setting the position of the menu to fixed and giving it a width of 100%.

```go-html-template
.floating-menu {
  position: fixed;
  width: 100%;
}
```

We'll also add some padding to the menu to give it some breathing room.

```go-html-template
.floating-menu {
  position: fixed;
  width: 100%;
  padding: 10px;
}
```

Next, we'll give our unordered list a display of inline-block to make it horizontal, and center it using text-align.

```go-html-template
.floating-menu ul {
  display: inline-block;
  text-align: center;
}
```

We'll also give each list item some margin to separate them, and make the links bold.

```go-html-template
.floating-menu li {
  display: inline-block;
  margin: 0 10px;
}

.floating-menu a {
  font-weight: bold;
}
```

Finally, we'll add a background color and some transparency to our menu using rgba, and a box shadow to give it some depth.

```go-html-template
.floating-menu {
  position: fixed;
  width: 100%;
  padding: 10px;
  background-color: rgba(124, 179, 52, 0.9);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
}
```

### Final Result

In HTML

```go-html-template
<div class="floating-menu">
  <ul>
    <li><a href="#">Home</a></li>
    <li><a href="#">About</a></li>
    <li><a href="#">Contact</a></li>
  </ul>
</div>
```

In CSS

```go-html-template
.floating-menu {
  position: fixed;
  width: 100%;
  padding: 10px;
  background-color: rgba(124, 179, 52, 0.9);
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.2);
}

.floating-menu ul {
  display: inline-block;
  text-align: center;
}

.floating-menu li {
  display: inline-block;
  margin: 0 10px;
}

.floating-menu a {
  font-weight: bold;
}
```

### Final Result

| ![floating menu with HTML and CSS.jpg](/post/images/html_and_css_final.png) |
| :-------------------------------------------------------------------------: |
|                      _floating menu with HTML and CSS_                      |

### Conclusion

In this blog post, we've gone over how to create a simple floating menu using HTML and CSS. By following these steps, you can create a floating menu that is not only functional, but also visually appealing.
