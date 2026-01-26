// CONFIGURATION
// Update this number to match how many images you have in the img/ folder
const TOTAL_IMAGES = 20; 

const quotes = [
    "It's not like I like you or anything, b-baka!",
    "Even if I die, you keep living okay?",
    "Simplicity is the easiest path to true beauty.",
    "Don't give up, there's no shame in falling down!",
    "I will always be by your side.",
    "The world is beautiful because you are in it.",
    "Believe in the me that believes in you!",
    "Sometimes, it takes a good fall to know where you stand.",
    "Power comes in response to a need, not a desire.",
    "Whatever you lose, you'll find it again.",
    "Fear is not evil. It tells you what your weakness is.",
    // Add more quotes here...
];

function getRandomInt(max) {
    return Math.floor(Math.random() * max) + 1;
}

function updateContent() {
    // 1. Pick a random image (1.jpg to 20.jpg)
    const randomImgNum = getRandomInt(TOTAL_IMAGES);
    const bgElement = document.getElementById('bg-image');
    
    // We set the background image of the div
    bgElement.style.backgroundImage = `url('img/${randomImgNum}.jpg')`;

    // 2. Pick a random quote
    const randomQuoteIndex = Math.floor(Math.random() * quotes.length);
    const quoteElement = document.getElementById('quote-text');
    
    quoteElement.innerText = `"${quotes[randomQuoteIndex]}"`;
}

document.addEventListener('keydown', function(e) {
    switch(e.key) {
        case 'Enter': // Center Key on Phone / Enter on Mac
            updateContent();
            break;
        case 'ArrowUp':
        case 'ArrowDown':
        case 'ArrowLeft':
        case 'ArrowRight':
            // These keys work on both Mac and KaiOS D-Pad automatically
            console.log("Direction key pressed");
            break;
        case 'SoftLeft': // The top-left button on the phone
            console.log("Left option pressed");
            break;
        case 'SoftRight': // The top-right button on the phone
            console.log("Right option pressed");
            break;
    }
});

// Initialize on load
window.addEventListener('load', function() {
    updateContent();
});