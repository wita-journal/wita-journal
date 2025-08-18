const fs = require('fs');


let SVG_CONTENT = '';
for (let itr = 0; itr <= 30; itr++) {
    let xx = 400 + itr * 20;
    let yy = 400 - Math.sin(itr/30 * Math.PI) * 250;

    // 75 212 -135 456
    let dx1 = 72 + itr * 5;
    let dy1 = 212 + itr * 13;
    let dx2 = -235 + itr * -15;
    let dy2 = 356 + itr * -13;

    let endX = xx - 650 + itr * 1;
    let endY = yy + 650 + Math.sin(itr / 30 * Math.PI) * 1000;

    const curve_str = [dx1, dy1, dx2, dy2, endX, endY].map(v => v.toFixed(2)).join(',');
    SVG_CONTENT += `<path d="M ${xx},${yy.toFixed(2)} c ${curve_str}" stroke="#FFDD0044" stroke-width="8" fill="none" />\n`;
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

