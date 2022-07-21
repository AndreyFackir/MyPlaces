//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Андрей Яфаркин on 18.07.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { //@IBDesignable позволит отобразить контент в интерфейс билдере, любые изменения будут отображаться в ИБ

    //iniit(frame:) - вью создается программно
    //init(coder:) -  для работы с элементом через сториборд
    
    
    private var ratingsButton = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
   // @IBInspectable для доавбления свойств инспектор, можно менять значения в инспекторе
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: - private Methods
    private func setupButtons () {
        
        for button in ratingsButton {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingsButton.removeAll()
        
        //Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        
        
        //создаем 5 кнопок
        for _ in 0..<starCount {
            
            let button =  UIButton()
        
            //set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            //add Constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            button.addTarget(self, action: #selector(ratingButtontapped), for: .touchUpInside)
            addArrangedSubview(button)
            
            ratingsButton.append(button)
            updateButtonSelectionStates()
        }
        
    }
    
    @objc func ratingButtontapped( button: UIButton) {
        
        guard let index = ratingsButton.firstIndex(of: button) else { return }//возвращает индекс первого выбраноного элемента
        
        //calculate rating of selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingsButton.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}
