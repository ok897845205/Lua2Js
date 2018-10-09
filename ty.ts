class Grid {
    static origin = {x: 0, y: 0};
    static l = 0;
    calculateDistanceFromOrigin(point: {x: number; y: number;}) {
        Grid.l = Grid.l + 1;
        console.log(Grid.l);

        var xDist = (point.x - Grid.origin.x);
        var yDist = (point.y - Grid.origin.y);
        return Math.sqrt(xDist * xDist + yDist * yDist) / this.scale;
    }
    constructor (public scale: number) { }
}

class GridParent extends Grid {
    constructor(scale: number) {
        super(scale);
    }
}

var grid1 = new GridParent(1.0);  // 1x scale
var grid2 = new GridParent(5.0);  // 5x scale

console.log(grid1.calculateDistanceFromOrigin({x: 10, y: 10}));
console.log(grid2.calculateDistanceFromOrigin({x: 10, y: 10}));