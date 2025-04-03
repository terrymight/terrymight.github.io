---
title: "Introduction to JavaScript Web Workers A Beginner's Guide"
description: ""
date: "2025-01-13T14:16:35+01:00"
publishDate: "2025-01-13T14:16:35+01:00"
tags: ["HTML", "JAVASCRIPT"]
categories: ["JAVASCRIPT"]
authors: ["Tejiri Mayone"]
---

{{< figure src="/post/images/web-worker.png" caption="Javascript Web Worker: A Beginner's Guide" >}}

<!--more-->

In modern web development, performance is a key factor for delivering a seamless user experience.

### Introduction

When JavaScript is tasked with heavy computations or long-running operations, it can block the main thread, causing the user interface to freeze or become unresponsive. This is where Web Workers come in handy. They allow you to run JavaScript code in the background, separate from the main thread, ensuring that your web application remains smooth and responsive.

In this blog, we will explore what Web Workers are, why they are useful, and how to create a simple Web Worker.

#### What Are Web Workers?

A Web Worker is a JavaScript script that runs in the background, independent of other scripts, without affecting the performance of the main thread. This means you can offload intensive tasks, such as data processing or API calls, to a Web Worker, leaving the main thread free to handle user interactions and updates to the UI.

#### Creating a Simple Web Worker

Let’s dive into a simple example to understand how Web Workers work. We will create a Web Worker that sort large float values.

#### Step 1: Create the Worker Script

Save the following code in a file called worker.js:

```go-html-template
onmessage = (e) => {
  console.log("Worker: Message received from main script");

  const result = e.data[0] * e.data[1];

  if (isNaN(result)) {
    postMessage("Please write two numbers");
  } else {
    const workerResult = "Result: " + result;
    console.log("Worker: Posting message back to main script");
    postMessage(workerResult);
  }
};
```

Here, the `onmessage` event listens for messages sent from the main thread. Once it receives an array of numbers, it sorts and sends the result back using `postMessage`.

#### Step 2: Use the Worker in the Main Script

In your `main.js` JavaScript file, create a Web Worker and communicate with it:

```go-html-template

const p = document.querySelectorAll('p')
const arrlength = document.querySelector('span')

const p1 = p[0]
const p2 = p[1]
const p3 = p[2]

/**
 * @returns array with n values
 */
function randomGenerator(n){
    const number = []
    for(let i = 0; i < n; i ++){
        number.push(Math.floor(Math.random() * 9999))
    }
    return number
}

/**
 * @param {*} func pass in our quick sort function for processing
 * @param {*} numbers values to be sorted
 * @returns sorted number && time take to complete
 */
function measureTime(func,numbers){

    if (window.Worker) {
        const myWorker = new Worker("worker.js");

    }
    const timeStart = performance.now()
    const sortedNumber = func(numbers)
    const endTime = performance.now()
    const timeTaken = endTime - timeStart
    return {sortedNumber, timeTaken}
}

/**
 * Number to generated
 */
const numb = 20

const randomNumb = randomGenerator(numb)

const {sortedNumber, timeTaken } = measureTime(sortjs,randomNumb)

// array length
arrlength.textContent = numb

// Random numbers
p1.textContent = randomNumb

// Sorted Number array
p2.textContent =sortedNumber

// Time take to complete the sorting
p3.textContent = timeTaken
```

#### Step 3: In index.html File

```go-html-template
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quick Sorting</title>
</head>

<body>

    <h3>Quick Sorting</h3>

    <h3>Generate <span></span> array length</h3>

    <h3>Random numbers</h3>
    <p></p>

    <h3>Sorted Number array</h3>
    <p></p>

    <h3>Time take to complete the sorting</h3>
    <p></p>
    <script src="js.js"></script>
</body>

</html>
```

#### In this code:

- A new Worker instance is created, pointing to the worker.js script.
- The postMessage method sends the array of numbers to the worker.
- The onmessage event handler processes the result returned by the worker.
- Errors are caught using the onerror event handler.

#### Advantages of Web Workers

1. Improved Performance: By offloading heavy tasks, Web Workers prevent UI freezes.
2. Thread Isolation: Tasks in Web Workers run independently, avoiding conflicts with the main thread.
3. Scalability: They can be used to handle multiple background tasks simultaneously.

#### Limitations of Web Workers

1. No DOM Access: Workers cannot directly manipulate the DOM.
2. Limited Browser Support: While most modern browsers support Web Workers, they may not work in older versions.
3. Overhead: Creating and managing multiple workers can consume additional memory and resources.
