var __extends = this.__extends || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
var Grid = (function () {
    function Grid(scale) {
        this.scale = scale;
    }
    Grid.prototype.calculateDistanceFromOrigin = function (point) {
        Grid.l = Grid.l + 1;
        console.log(Grid.l);

        var xDist = (point.x - Grid.origin.x);
        var yDist = (point.y - Grid.origin.y);
        return Math.sqrt(xDist * xDist + yDist * yDist) / this.scale;
    };
    Grid.origin = { x: 0, y: 0 };
    Grid.l = 0;
    return Grid;
})();

var GridParent = (function (_super) {
    __extends(GridParent, _super);
    function GridParent(scale) {
        _super.call(this, scale);
    }
    return GridParent;
})(Grid);

var grid1 = new GridParent(1.0);
var grid2 = new GridParent(5.0);

console.log(grid1.calculateDistanceFromOrigin({ x: 10, y: 10 }));
console.log(grid2.calculateDistanceFromOrigin({ x: 10, y: 10 }));
