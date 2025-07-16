const fs = require('fs');

const COLOR_YELLOW = '#0099FF11';

let SVG_CONTENT = '';
for (let itr = 0; itr <= 30; itr++) {
    // M 0 0 c 46 94 62 282 -25 400

    let dx1 = 146;
    let dy1 = 184 + -10 * itr;
    let dx2 = -152;
    let dy2 = 302 + 9 * itr;

    let endX = 625 + -15 * itr;
    let endY = 750 + 0.1 * itr;

    const curve_str = [dx1, dy1, dx2, dy2, endX, endY].map(v => (v * (3 + 0.1 * itr)).toFixed(2)).join(',');
    SVG_CONTENT += `<path transform="translate(${itr*60},${itr*-5}) rotate(${itr * 1.5})" d="M 0,0 c ${curve_str}" stroke="${COLOR_YELLOW}" stroke-width="8" fill="none" />\n`;
};

let SGV_OUTPUT = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1500 2100">
    <defs>
        <mask id="main_canvas_zone">
            <rect x="90" y="90" width="1320" height="1920" fill="white" />
        </mask>
    </defs>

    <rect x="0" y="0" width="1500" height="2100" fill="#FAFAFA00" />

    <g mask="url(#main_canvas_zone)">
    ${SVG_CONTENT}
    </g>
</svg>
`;


const svg_path = process.argv[1] + '.svg';
fs.writeFileSync(svg_path, SGV_OUTPUT);

