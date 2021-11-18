//
//  InteractionControlling.swift
//  PinchToOpen
//
//  Created by Mat Schmid on 2021-11-17.
//

import UIKit

protocol InteractionControlling: UIViewControllerInteractiveTransitioning {
	var interactionInProgress: Bool { get }
}
