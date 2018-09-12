//
//  SimpleBarGraph.swift
//  BarGraphDemo
//
//  Created by Sameer mhatre on 12/09/18.
//

import Foundation
import UIKit
struct BarEntry {
    
    let color: UIColor
    let height: Float
    /// To be shown at the bottom of the bar
    let title: String
}
class SimpleBarGraph: UIView {
    
    @IBInspectable var barWidth: CGFloat = 10
    
    /// space between each bar
    @IBInspectable var space: CGFloat = 20
    
    /// space at the bottom of the bar to show the title
    @IBInspectable var bottomSpace: CGFloat = 0
    
    /// space at the top of each bar to show the value
    @IBInspectable var topSpace: CGFloat = 0
    
    @IBInspectable var numberOFCountBar: CGFloat = 20
  
    
    @IBInspectable var startFrom: CGFloat = 250
    @IBInspectable var differnce: CGFloat = 50
    @IBInspectable var sidePadding: CGFloat = 10
    @IBInspectable var numberOFLine: CGFloat = 10
    @IBInspectable var lineWidth: CGFloat = 1
    @IBInspectable var lineColor: UIColor = UIColor.lightGray
    
    var dataEntries: [BarEntry]? = nil {
        didSet {
            mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
            
            if let dataEntries = dataEntries {
                scrollView.contentSize = CGSize(width: (barWidth + space)*CGFloat(dataEntries.count)+self.space, height: self.scrollView.frame.size.height-20)
                mainLayer.frame = CGRect(x: 0, y: 11, width: scrollView.contentSize.width, height: (scrollView.contentSize.height-18) + 20)
               // mainLayer.backgroundColor = UIColor.red.withAlphaComponent(0.2).cgColor
                for i in 0..<dataEntries.count {
                    showEntry(index: i, entry: dataEntries[i])
                    print(dataEntries[i].height)
                }
                
               
            }
        }
    }
    
    /// contain all layers of the chart
    private let mainLayer: CALayer = CALayer()
    
    /// contain mainLayer to support scrolling
    private let scrollView: UIScrollView = UIScrollView()
    
    override func draw(_ rect: CGRect)
    {
        
        var count = self.startFrom-self.differnce
        for i in stride(from:numberOFLine, to: 0, by: -1)
        {
            count = count + differnce
            let item = (self.frame.size.height-20)/numberOFLine
            self.drowLines(gap: Float(CGFloat(i) * item))
            let _rect1 = CGRect(x: 0, y: CGFloat(Float(CGFloat(i) * item-7))-7, width: 40, height: 40)
            drawMyText(myText: "\(Int(count))", textColor: lineColor, FontName: "Helvetica Bold", FontSize: 11 , inRect:_rect1)
        }
        scrollView.contentSize = CGSize(width: self.frame.width, height: self.scrollView.frame.size.height-20)
        mainLayer.frame = CGRect(x: 0, y: 11, width: scrollView.contentSize.width, height: (scrollView.contentSize.height-18) + 20)
        setupView()
        layoutSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        scrollView.layer.addSublayer(mainLayer)
        self.addSubview(scrollView)
      
    }
    
    override func layoutSubviews()
    {
        
        scrollView.frame = CGRect(x: 40, y: 0, width: self.frame.size.width-50, height: self.frame.size.height)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    private func showEntry(index: Int, entry: BarEntry) {
        /// Starting x postion of the bar
        let xPos: CGFloat = space + CGFloat(index) * (barWidth + space)
        
        /// Starting y postion of the bar
        let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
        
        drawTitle(xPos: xPos - space/2, yPos: (mainLayer.frame.height-15) - bottomSpace, title: entry.title, color: entry.color)
        drawBar(xPos: xPos, yPos: yPos, color: entry.color)
    }
    private func translateHeightValueToYPosition(value: Float) -> CGFloat {
        let height: CGFloat = CGFloat(value) * ((mainLayer.frame.height-20) - bottomSpace - topSpace)
        return (mainLayer.frame.height-20) - bottomSpace - height
    }
    private func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
        let barLayer = CALayer()
        barLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth, height: (mainLayer.frame.height-20) - bottomSpace - yPos)
        barLayer.backgroundColor = color.cgColor
        barLayer.cornerRadius = self.barWidth/2
        barLayer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainLayer.addSublayer(barLayer)
        let oldBounds = CGRect(x: xPos, y: 0, width: barWidth, height: 0)
        let newBounds = CGRect(x: xPos, y: yPos, width: barWidth, height: (mainLayer.frame.height-20) - bottomSpace - yPos)
        let revealAnimation = CABasicAnimation(keyPath: "bounds")
        revealAnimation.fromValue =  oldBounds
        revealAnimation.toValue = newBounds
        revealAnimation.duration = 0.9
        barLayer.bounds = newBounds
        barLayer.add(revealAnimation, forKey: "revealAnimation")
        
    
    }
    private func drawTitle(xPos: CGFloat, yPos: CGFloat, title: String, color: UIColor) {
        let textLayer = CATextLayer()
        
       
        textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth + space, height: 20)
        textLayer.foregroundColor = self.lineColor.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
        textLayer.fontSize = 10
        textLayer.string = title
        mainLayer.addSublayer(textLayer)
    }
    func drawMyText(myText:String,textColor:UIColor, FontName:String, FontSize:CGFloat, inRect:CGRect)
    {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributes = [NSAttributedStringKey.font: UIFont(name: FontName, size: FontSize)!,
                          NSAttributedStringKey.foregroundColor: textColor,NSAttributedStringKey.paragraphStyle: style]
        myText.draw(in: inRect, withAttributes: attributes)
        
    }
    func drowLines(gap:Float)
    {
        
        let path = UIBezierPath()
        path.lineWidth = self.lineWidth
        path.move(to: CGPoint(x: 30+sidePadding+0.0, y: CGFloat(gap-7)))
        path.addLine(to: CGPoint(x: self.frame.size.width-sidePadding, y:CGFloat(gap-7) ))
        path.close()
        self.lineColor.setStroke()
        path.stroke()
        
    }
    
}
