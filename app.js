// CONFIGURATION
// Update this number to match how many images you have in the img/ folder
const TOTAL_IMAGES = 33; 



const quotes = [
    "Just a little reminder that I'm yours—and I choose you every single day.",
    "Thinking about you makes me feel beautiful, even when no one else can see me.",
    "I hope this picture finds you smiling… because you're the reason I am.",
    "Every version of me is better because it's loved by you.",
    "I love the way our future feels when I imagine it with you.",
    "This is me, missing you, and loving you at the same time.",
    "You make me feel safe enough to dream bigger.",
    "If you were here right now, I'd be holding you instead of my phone.",
    "I still get butterflies knowing I'm yours.",
    "I hope you see in my eyes what my heart already knows.",
    "I'm becoming the woman I've always wanted to be—because I'm loved by you.",
    "This smile is yours. You earned it.",
    "I want a lifetime of moments like this… shared with you.",
    "I love the way you look at me, even when you're not here.",
    "Just me, feeling close to you, even from afar.",
    "Being loved by you has changed the way I see myself.",
    "I carry you with me—everywhere, always.",
    "You make ordinary days feel quietly magical.",
    "This is what happiness looks like when it misses you.",
    "I feel most like myself when I'm yours.",
    "I love the future we're building, one heartbeat at a time.",
    "I hope you feel how much I want you—even through a screen.",
    "You make me feel desired, cherished, and deeply seen.",
    "This picture is just a glimpse… my heart belongs entirely to you.",
    "I want to grow old still making eyes at you.",
    "I love knowing I'm yours, and you're mine.",
    "Every day with you feels like a promise.",
    "I feel strong, soft, and safe all at once—because of you.",
    "I can't wait to be wrapped up in you again.",
    "You're my favorite thought when the world goes quiet.",
    "I hope you feel how close I am to you right now.",
    "I love who I am when I'm loved by you.",
    "This smile comes from thinking about us.",
    "No matter where we are, my heart knows where it belongs.",
    "I want you to see me the way I feel with you.",
    "I still blush when I think about how much you love me.",
    "Being yours is my favorite kind of beautiful.",
    "I believe in us—today, tomorrow, always.",
    "I hope this picture reminds you how deeply wanted you are.",
    "You make my heart feel at home.",
    "I love the quiet intimacy of just being yours.",
    "I want a life full of moments that feel like this.",
    "You make me feel desired without saying a word.",
    "This is me, loving you from wherever I am.",
    "I fall in love with you again in the smallest moments.",
    "I hope you feel how close my heart is to yours.",
    "I want to keep choosing you for the rest of my life.",
    "You make love feel easy and endless.",
    "This look is for you—and only you.",
    "I'm yours. Still. Always.",
    "Just casually thinking about how lucky I am that you're mine.",
    "Warning: this picture comes with a strong urge to kiss me.",
    "I smiled for no reason… then remembered you.",
    "Tell me again how we ended up this cute.",
    "I was going to behave today, but then I thought of you.",
    "This is your daily reminder that your wife is hot and loves you.",
    "If I were there, I'd be stealing your hoodie.",
    "I took this picture and immediately thought: yep, he's mine.",
    "You still make me blush, and that feels unfair.",
    "Just me, being a little obsessed with my husband.",
    "I hope this distracts you—in a good way.",
    "I like knowing I get to flirt with you for the rest of my life.",
    "I caught myself smiling at my phone again. It's your fault.",
    "I love that I get to call you mine.",
    "This face is what happens when I think about you too long.",
    "You make being married feel like a secret crush.",
    "I'd rather be annoying you right now.",
    "I still get excited when I know you're thinking about me.",
    "You're my favorite notification.",
    "I promise I looked like this just for you.",
    "I love that I still want you the way I do.",
    "I hope you're prepared for me later.",
    "You have no idea what I'm thinking right now.",
    "I like knowing you're the one who gets this picture.",
    "Married to you still feels like winning.",
    "If I were there, I'd be distracting you on purpose.",
    "I love that I get to be yours in all the ways.",
    "I took this and smiled because I know you'll like it.",
    "You still make my heart race, which seems important.",
    "I like being the reason you smile today.",
    "I love being wanted by you.",
    "This is me, feeling cute and thinking about you.",
    "I hope this makes your day a little better.",
    "You make flirting feel effortless.",
    "I love knowing exactly who I belong to.",
    "I might be smiling too much right now.",
    "You're my favorite kind of trouble.",
    "I love that I get to tease you like this.",
    "You crossed my mind… and now you're stuck there.",
    "I still get excited to send you pictures like this.",
    "I like being the one who gets your attention.",
    "Just checking in to remind you I'm yours.",
    "I love that you get this version of me.",
    "I hope this makes you think about me all day.",
    "I like knowing you're looking at me right now.",
    "I love being your wife.",
    "You make this fun.",
    "I'm smiling because I know you'll smile too.",
    "This is me, being yours on purpose.",
    "This picture is me wanting to be close to you.",
    "I wish you could feel how much I want you right now.",
    "I love the way you make me feel desired.",
    "This is me, thinking about being in your arms.",
    "I feel closest to you when I let myself miss you.",
    "I love knowing my body is wanted by you.",
    "I want to feel your hands on me again.",
    "This is me, soft and open, thinking about you.",
    "I like knowing you're the one who sees me like this.",
    "I feel safe letting you see all of me.",
    "I want to be close enough to hear your breathing.",
    "This picture is a whisper meant just for you.",
    "I love how deeply you know me.",
    "I want you to feel how much I want you.",
    "I'm thinking about being wrapped up in you.",
    "I love that my desire belongs to you.",
    "This is me, wanting your attention and your touch.",
    "I want to feel you pull me closer.",
    "I love how intimate it feels just being yours.",
    "I'm missing your warmth.",
    "I want you to look at me the way only you do.",
    "This is me, feeling connected to you.",
    "I love the quiet closeness we share.",
    "I want to feel your presence around me.",
    "I love knowing you want me like this.",
    "This picture is me wanting to be near you.",
    "I feel open with you in a way I don't with anyone else.",
    "I love that my body feels like home to you.",
    "I'm thinking about your touch.",
    "I want to be close enough to melt into you.",
    "This is me, longing for you.",
    "I love the intimacy we've built together.",
    "I want to feel you hold me.",
    "I love knowing I'm desired by you.",
    "This picture is meant for your eyes only.",
    "I feel deeply connected to you right now.",
    "I want to feel your closeness again.",
    "I love how safe it feels to want you.",
    "This is me, thinking about us.",
    "I want to be wrapped up in your arms.",
    "I love sharing this side of me with you.",
    "I feel wanted, and it's because of you.",
    "I want you to feel how much I miss you.",
    "This is me, open and yours.",
    "I love how intimate it feels just to be seen by you.",
    "I want to feel you close to me.",
    "I love that my desire belongs with you.",
    "This is me, wanting you.",
    "I feel closest to you when I let myself feel this.",
    "I'm yours—in every way that matters.",
    "It's not like I like you or anything, b-baka!",
    "I will always be by your side.",
    "The world is beautiful because you are in it.",
    "Believe in the me that believes in you!",
    "Whatever you lose, you'll find it again.",
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
