import Foundation

final class FillWithColor {
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        
        if (image.count == 0) {return image}
        if ((row < 0) || (row >= image.count) || (column < 0) || (column >= image[row].count)) {return image}
        var img = image
        let startPixel = image[row][column]
        
        if (startPixel == newColor) {return image}
        
        func goRULD(img: inout [[Int]], r: Int, c: Int) {
            if ((r < 0) || (r >= img.count) || (c < 0) || (c >= img[0].count) || (img[r][c] != startPixel)) {return}
            
            img[r][c] = newColor
            
            goRULD(img: &img, r: r ,c: c + 1)
            goRULD(img: &img, r: r + 1 ,c: c)
            goRULD(img: &img, r: r ,c: c - 1)
            goRULD(img: &img, r: r - 1 ,c: c)
        }
        
        goRULD(img: &img,r: row,c: column)
        
        return img
    }
}
