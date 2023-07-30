//browser.runtime.sendMessage({ greeting: "hello" }).then((response) => {
//    console.log("Received response: ", response);
//});
//
//browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    console.log("Received request: ", request);
//});

document.querySelectorAll('a').forEach(link => {
    if (link && link.href) {
        try {
            let url = new URL(link.href);
            if (url.hostname.includes('reddit.com')) {
                link.href = link.href.replace(/(https?:\/\/)?(www\.)?reddit\.com/gi, 'https://app.winston.lo.cafe');
            }
        } catch (e) {
            console.error('Invalid URL', link.href);
        }
    }
});
