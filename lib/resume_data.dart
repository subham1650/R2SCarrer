class ResumeData {
  String name = '';
  String profession = '';
  String phone = '';
  String email = '';
  String address = '';
  String website = '';
  String linkedIn = '';
  String portfolio = '';
  String about = ''; // can also be considered a summary/objective

  List<Education> education = [Education()];
  List<Experience> experience = [Experience()];
  List<String> skills = [''];
  List<Reference> references = [Reference()];
  List<Certification> certifications = [Certification()];
  List<Project> projects = [Project()];
  List<String> languages = [''];
  List<String> keywords = [''];
  List<Achievement> achievements = [Achievement()];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profession': profession,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'linkedIn': linkedIn,
      'portfolio': portfolio,
      'about': about,
      'education': education.map((e) => e.toJson()).toList(),
      'experience': experience.map((e) => e.toJson()).toList(),
      'skills': skills,
      'references': references.map((e) => e.toJson()).toList(),
      'certifications': certifications.map((c) => c.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'languages': languages,
      'keywords': keywords,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }
}

class Education {
  String degree = '';
  String university = '';
  String year = '';
  String description = '';

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'university': university,
        'year': year,
        'description': description,
      };
}

class Experience {
  String position = '';
  String company = '';
  String year = '';
  String description = '';

  get bulletPoints => null;

  Map<String, dynamic> toJson() => {
        'position': position,
        'company': company,
        'year': year,
        'description': description,
      };
}

class Reference {
  String name = '';
  String position = '';
  String contact = '';

  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'contact': contact,
      };
}

class Certification {
  String title = '';
  String organization = '';
  String year = '';

  Map<String, dynamic> toJson() => {
        'title': title,
        'organization': organization,
        'year': year,
      };
}

class Project {
  String name = '';
  String description = '';
  String techStack = '';
  String link = '';

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'techStack': techStack,
        'link': link,
      };
}

class Achievement {
  String title = '';
  String description = '';
  String year = '';

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'year': year,
      };
}
