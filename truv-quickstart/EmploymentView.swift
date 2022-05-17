//
//  EmploymentView.swift
//  truv-quickstart
//
//  Created by Rey Riel on 1/31/21.
//

import UIKit

class EmploymentView: UIStackView {
    var firstName: String? = ""
    var lastName: String? = ""
    var dob: String? = ""
    var ssn: String? = ""
    var employerName: String? = ""
    var employerPhone: String? = ""
    var employerCity: String? = ""
    var employerState: String? = ""
    var positionType: String? = ""
    var title: String? = ""
    var startDate: String? = ""
    var endDate: String? = ""
    
    lazy var firstNameLabel: UIStackView = {
        return createStackLabel(name: "First Name:", value: firstName)
      }()
    lazy var lastNameLabel: UIStackView = {
        return createStackLabel(name: "Last Name:", value: lastName)
      }()
    lazy var dobLabel: UIStackView = {
        return createStackLabel(name: "Date of Birth:", value: dob)
      }()
    lazy var ssnLabel: UIStackView = {
        return createStackLabel(name: "SSN:", value: ssn)
      }()
    
    lazy var eNameLabel: UIStackView = {
        return createStackLabel(name: "Employer:", value: employerName)
      }()
    lazy var ePhoneLabel: UIStackView = {
        return createStackLabel(name: "Employer Phone:", value: employerPhone)
      }()
    lazy var eCityLabel: UIStackView = {
        return createStackLabel(name: "Employer City:", value: employerCity)
      }()
    lazy var eStateLabel: UIStackView = {
        return createStackLabel(name: "Employer State:", value: employerState)
      }()
    
    lazy var jobTitleLabel: UIStackView = {
        return createStackLabel(name: "Job Title:", value: title)
      }()
    lazy var positionTypeLabel: UIStackView = {
        return createStackLabel(name: "Position Type:", value: positionType)
      }()
    lazy var startDateLabel: UIStackView = {
        return createStackLabel(name: "Start Date:", value: startDate)
      }()
    lazy var endDateLabel: UIStackView = {
        return createStackLabel(name: "End Date:", value: endDate)
      }()
    
    required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    
    init(data: [String: Any]) {
        let employment = (data["employments"] as! [[String: Any]])[0]
        let profile = employment["profile"] as! [String: Any]
        let employer = employment["company"] as! [String: Any]
        
        
        super.init(frame: .zero)
        
        setEmploymentValues(employment: employment)
        setProfileValues(profile: profile)
        setEmployerValues(employer: employer)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .fillEqually
        self.spacing = UIStackView.spacingUseSystem
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        addArrangedSubview(firstNameLabel)
        addArrangedSubview(lastNameLabel)
        addArrangedSubview(dobLabel)
        addArrangedSubview(ssnLabel)
        addArrangedSubview(eNameLabel)
        addArrangedSubview(ePhoneLabel)
        addArrangedSubview(eCityLabel)
        addArrangedSubview(eStateLabel)
        addArrangedSubview(jobTitleLabel)
        addArrangedSubview(positionTypeLabel)
        addArrangedSubview(startDateLabel)
        addArrangedSubview(endDateLabel)
        
    }
    
    func setProfileValues(profile: [String: Any]) {
        firstName = profile["first_name"] as? String
        lastName = profile["last_name"] as? String
        dob = profile["date_of_birth"] as? String
        ssn = profile["ssn"] as? String
    }
    
    func setEmploymentValues(employment: [String: Any]) {
        positionType = employment["job_type"] as? String
        title = employment["job_title"] as? String
        startDate = employment["start_date"] as? String
        endDate = employment["end_date"] as? String
    }
    
    func setEmployerValues(employer: [String: Any]) {
        employerName = employer["name"] as? String
        employerPhone = employer["phone"] as? String
        let address = employer["address"] as! [String: Any]
        employerCity = address["city"] as? String
        employerState = address["state"] as? String
    }
    
    func createStackLabel(name: String, value: String?) -> UIStackView {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        title.textColor = UIColor.black
        title.textAlignment = .left
        title.text = name
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.text = value ?? ""
        
        let stack = UIStackView(arrangedSubviews: [title, label])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fillEqually
        
        return stack
    }
}
