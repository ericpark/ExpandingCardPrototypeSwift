//
//  CardViewController.swift
//  ExpandingCardPrototypeSwift
//
//  Created by Eric Park on 6/25/17.
//  Copyright © 2017 Eric Park. All rights reserved.
//

import UIKit

enum ConstraintDirection{
    case ConstraintDirectionTop
    case ConstraintDirectionLeft
    case ConstraintDirectionBottom
    case ConstraintDirectionRight
}

let kCardPaddingPercentTop: CGFloat = 0.1
let kCardPaddingPercentSide: CGFloat = 0.1
let kTableViewCellHeight: CGFloat = 100.0;
let kCardCornerRadius: CGFloat = 10.0
let kTableCellReuseId:String = "TableCellReuseId"

class CardViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    

    
    @IBOutlet weak var bigContainerView: UIView!
    @IBOutlet weak var bigScrollView: UIScrollView!
    @IBOutlet weak var smallContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var smallScrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallScrollViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallScrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var smallScrollViewRightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.setupBigScrollView()
        self.setupSmallContainerView()
        self.setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBigScrollView(){
        let height: CGFloat = CGFloat(self.tableView.numberOfRows(inSection: 0)) * kTableViewCellHeight + maxYOffsetBeforeScrolling()
        self.bigScrollView.contentSize = CGSize(width: self.view.frame.width, height: height);

    }
    
    func setupSmallContainerView(){
        self.updateCardViewConstraintsForOffset(offset: 0.0)
        self.smallContainerView.layer.cornerRadius = kCardCornerRadius
        self.smallContainerView.clipsToBounds = true
        //self.bigScrollView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.didSwipeCard)))
    }
    
    func setupTableView(){
        self.tableView.removeGestureRecognizer(self.tableView.panGestureRecognizer)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kTableCellReuseId)
    }
    
    // MARK: - Changing Table Placement
    
    func expandTableViewFully(){
        self.updateCardViewConstraintsForOffset(offset: offsetForExpandedTableView().y)
    }
    
    func collapseTableViewFully(){
        self.updateCardViewConstraintsForOffset(offset: offsetForCollapsedTableView().y)

    }
    
    func offsetForExpandedTableView() -> CGPoint{
        return CGPoint(x:0.0, y:maxYOffsetBeforeScrolling() + 1)
    }
    
    func offsetForCollapsedTableView() -> CGPoint{
        return CGPoint(x:0.0, y:0.0)

    }
    
    func updateCardViewConstraintsForOffset(offset: CGFloat){
        self.smallScrollViewTopConstraint.constant = constraintSizeForOffset(offset: offset, constraintDirection: .ConstraintDirectionTop)
        self.smallScrollViewLeftConstraint.constant = constraintSizeForOffset(offset: offset, constraintDirection: .ConstraintDirectionLeft)
        self.smallScrollViewBottomConstraint.constant = constraintSizeForOffset(offset: offset, constraintDirection: .ConstraintDirectionBottom)
        self.smallScrollViewRightConstraint.constant = constraintSizeForOffset(offset: offset, constraintDirection: .ConstraintDirectionRight)
    }
    
    // MARK: - UIScrollViewDelegate / Helpers
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == self.bigScrollView){
            let maxYOffsetForSmallScrollView: CGFloat = maxYOffsetBeforeScrolling()
            let yOffset: CGFloat = scrollView.contentOffset.y
            if (yOffset <= maxYOffsetForSmallScrollView){
                updateCardViewConstraintsForOffset(offset: yOffset)
                self.tableView.contentOffset = CGPoint(x:0, y: 0)
                if (self.smallContainerView.layer.cornerRadius != kCardCornerRadius){
                    self.smallContainerView.layer.cornerRadius = kCardCornerRadius
                }
            }
            else{
                if (self.smallScrollViewTopConstraint.constant != 0.0) {
                    self.expandTableViewFully()
                }
                self.tableView.contentOffset = CGPoint(x: 0, y: (yOffset - maxYOffsetForSmallScrollView));
                if (self.smallContainerView.layer.cornerRadius != 0.0) {
                    self.smallContainerView.layer.cornerRadius = 0.0;
                }
            }

        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrollDistanceBeforeInFullScreenMode: CGFloat = maxYOffsetBeforeScrolling()
        if (targetContentOffset.pointee.y < maxYOffsetBeforeScrolling()){
            if (targetContentOffset.pointee.y < scrollDistanceBeforeInFullScreenMode/2.0 ){
                targetContentOffset.pointee = offsetForCollapsedTableView()
            }
            else{
                targetContentOffset.pointee = offsetForExpandedTableView()
            }
        }
    }
    
    // MARK: - Size Helpers
    
    func constraintSizeForOffset(offset: CGFloat, constraintDirection: ConstraintDirection) -> CGFloat{
        let sizeOfScreen: CGSize = self.view.bounds.size
        let scrollDistanceBeforeInFullScreenMode: CGFloat = maxYOffsetBeforeScrolling()
        let scalingFactor: CGFloat = min(1, (scrollDistanceBeforeInFullScreenMode - offset) / scrollDistanceBeforeInFullScreenMode)
        var originalConstraintSize:CGFloat
        if (constraintDirection == .ConstraintDirectionTop || constraintDirection == .ConstraintDirectionBottom) {
            originalConstraintSize = sizeOfScreen.height * kCardPaddingPercentTop
        }
        else {
            originalConstraintSize = sizeOfScreen.width * kCardPaddingPercentSide
        }
        return max(0, originalConstraintSize * scalingFactor)
    }
    
    func maxYOffsetBeforeScrolling() -> CGFloat{
        return self.view.bounds.size.height * kCardPaddingPercentTop;
    }
    
    // MARK: - UITableViewDelegate / UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: kTableCellReuseId, for: indexPath as IndexPath)
        cell.textLabel?.text = "Row Num: \(indexPath.row + 1)"
        cell.contentView.backgroundColor = UIColor.lightGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kTableViewCellHeight;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
