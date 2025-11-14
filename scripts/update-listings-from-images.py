#!/usr/bin/env python3
"""
Update listing titles and descriptions based on actual objects in images.
This script:
1. Reads listing data with image filenames
2. Extracts object information from filenames
3. Generates detailed titles (100+ chars) and descriptions (500+ chars)
4. Updates the database
"""

import os
import re
import sys
import subprocess
from pathlib import Path

# Configuration
DB_HOST = "localhost"
DB_PORT = "3306"
DB_USER = "root"
DB_PASSWORD = "root"
DB_NAME = "tradenbysell"

def extract_object_from_filename(filename):
    """Extract object name from filename"""
    # Remove extension
    name = os.path.splitext(filename)[0]
    # Remove counter suffixes like _1, _2, etc.
    name = re.sub(r'_\d+$', '', name)
    return name

def generate_title(object_name, category, listing_id):
    """Generate a detailed title (100+ chars) based on object"""
    object_name = object_name.replace('_', ' ').title()
    
    # Category-specific title templates
    templates = {
        'monitor': [
            f"Premium {object_name} Display Screen - High Resolution LED/LCD Monitor Perfect for Home Office, Gaming, and Professional Workstations with Excellent Picture Quality and Modern Design",
            f"Used {object_name} Computer Screen - Reliable Display Monitor Ideal for Students, Remote Workers, and Digital Professionals Seeking Quality Visual Experience at Affordable Price",
            f"Pre-owned {object_name} Display Monitor - Well-Maintained Screen with Clear Display, Multiple Connectivity Options, and Energy-Efficient Design Perfect for Campus and Hostel Use"
        ],
        'bicycle': [
            f"Quality {object_name} for Sale - Well-Maintained Two-Wheeler Perfect for Campus Commuting, Daily Exercise, and Eco-Friendly Transportation with Smooth Ride and Good Condition",
            f"Used {object_name} Bike - Reliable Cycle in Excellent Working Condition Ideal for Students, Fitness Enthusiasts, and Daily Commuters Seeking Affordable and Sustainable Mobility Solution",
            f"Pre-owned {object_name} - Durable Bicycle with All Components Working Perfectly, Great for Short Distance Travel, Exercise, and Environmentally Conscious Transportation Needs"
        ],
        'mattress': [
            f"Comfortable {object_name} for Sale - High-Quality Bed Mattress in Good Condition Perfect for Hostel Rooms, Dormitories, and Student Accommodations with Proper Support and Cleanliness",
            f"Used {object_name} Bed Mattress - Well-Maintained Sleeping Surface Ideal for Students, Young Professionals, and Anyone Seeking Quality Rest at an Affordable Price Point",
            f"Pre-owned {object_name} - Durable Mattress with Good Firmness and Support, Clean and Hygienic, Perfect for Single Bed Frames and Compact Living Spaces"
        ],
        'chair': [
            f"Ergonomic {object_name} for Study and Work - Comfortable Seating Solution Perfect for Long Study Sessions, Home Office Setup, and Academic Work with Proper Back Support",
            f"Used {object_name} - Well-Built Seating Furniture in Good Condition Ideal for Students, Remote Workers, and Anyone Seeking Comfortable and Affordable Office or Study Chair",
            f"Quality {object_name} Available - Durable Chair with Good Padding and Support, Perfect for Desk Work, Reading, and Extended Sitting Sessions in Dorm Rooms and Study Areas"
        ],
        'table': [
            f"Study {object_name} for Sale - Spacious Work Surface Perfect for Laptops, Books, and Study Materials with Sturdy Construction and Ample Space for Academic and Professional Work",
            f"Used {object_name} Desk - Well-Maintained Study Surface Ideal for Students, Remote Workers, and Anyone Seeking Functional Workspace Furniture at an Affordable Price",
            f"Pre-owned {object_name} - Durable Work Table with Good Surface Area, Stable Legs, and Practical Design Perfect for Hostel Rooms, Study Areas, and Compact Living Spaces"
        ],
        'headphone': [
            f"Quality {object_name} Audio Device - High-Performance Sound Equipment Perfect for Music Lovers, Online Classes, Video Calls, and Immersive Audio Experience with Clear Sound Quality",
            f"Used {object_name} - Well-Maintained Audio Accessory in Good Working Condition Ideal for Students, Professionals, and Anyone Seeking Quality Sound at an Affordable Price",
            f"Pre-owned {object_name} - Reliable Audio Device with Good Sound Quality, Comfortable Fit, and Durable Build Perfect for Campus Life, Commuting, and Personal Entertainment"
        ],
        'phone': [
            f"Smart {object_name} Device for Sale - Modern Mobile Phone in Good Working Condition with All Features Functional, Perfect for Daily Communication, Social Media, and Productivity Needs",
            f"Used {object_name} - Well-Maintained Smartphone with Good Battery Life, Clear Display, and Reliable Performance Ideal for Students and Young Professionals Seeking Affordable Technology",
            f"Pre-owned {object_name} - Quality Mobile Device with All Essential Features Working, Great Camera, and Smooth Performance Perfect for Campus Life and Everyday Communication"
        ],
        'cooler': [
            f"Efficient {object_name} Appliance - Energy-Saving Air Cooling System Perfect for Hot Weather, Dorm Rooms, and Small Living Spaces with Good Cooling Capacity and Low Power Consumption",
            f"Used {object_name} - Well-Maintained Cooling Device in Good Working Condition Ideal for Students, Hostel Residents, and Anyone Seeking Affordable Climate Control Solution",
            f"Pre-owned {object_name} - Reliable Air Cooler with Good Airflow, Easy Operation, and Effective Cooling Performance Perfect for Compact Spaces and Budget-Conscious Buyers"
        ],
        'sneaker': [
            f"Quality {object_name} Footwear - Comfortable Athletic Shoes in Good Condition Perfect for Sports, Gym Workouts, Daily Walking, and Active Lifestyle with Good Traction and Support",
            f"Used {object_name} - Well-Maintained Sports Shoes Ideal for Fitness Enthusiasts, Athletes, and Anyone Seeking Comfortable and Durable Footwear for Exercise and Casual Wear",
            f"Pre-owned {object_name} - Durable Athletic Footwear with Good Cushioning, Proper Fit, and Reliable Performance Perfect for Running, Sports Activities, and Everyday Comfort"
        ],
        'backpack': [
            f"Spacious {object_name} Bag - Durable Carrying Solution Perfect for Students, Travelers, and Daily Commuters with Multiple Compartments, Comfortable Straps, and Practical Design",
            f"Used {object_name} - Well-Maintained Carrying Bag in Good Condition Ideal for Campus Life, Books, Laptops, and Everyday Essentials with Good Storage Capacity and Durability",
            f"Quality {object_name} Available - Reliable Bag with Multiple Pockets, Strong Zippers, and Comfortable Shoulder Straps Perfect for Academic Use, Travel, and Daily Transportation Needs"
        ],
        'bed': [
            f"Comfortable {object_name} Frame - Sturdy Sleeping Furniture Perfect for Hostel Rooms, Dormitories, and Student Accommodations with Good Build Quality and Space-Efficient Design",
            f"Used {object_name} - Well-Maintained Bed Frame in Good Condition Ideal for Single Occupancy Rooms, Compact Living Spaces, and Anyone Seeking Affordable Sleeping Furniture",
            f"Pre-owned {object_name} - Durable Bed Structure with Stable Frame, Good Support, and Practical Design Perfect for Student Housing and Budget-Conscious Living Arrangements"
        ]
    }
    
    # Find matching template
    for key, template_list in templates.items():
        if key in object_name.lower():
            import random
            return random.choice(template_list)
    
    # Generic template for unknown objects
    return f"Quality {object_name.replace('_', ' ').title()} Item for Sale - Well-Maintained Product in Good Condition Perfect for Students, Campus Life, and Everyday Use with Practical Functionality and Affordable Pricing"

def generate_description(object_name, category, title):
    """Generate a detailed description (500+ chars) based on object"""
    object_name = object_name.replace('_', ' ').title()
    
    # Category-specific description templates
    descriptions = {
        'monitor': f"""This {object_name} is a high-quality display screen that has been carefully used and well-maintained. The monitor features excellent picture quality with clear resolution, making it perfect for various applications including academic work, professional tasks, online classes, gaming, and entertainment purposes.

The display offers vibrant colors and sharp text rendering, which is essential for extended reading sessions, coding, design work, and multimedia consumption. It comes with multiple connectivity options including HDMI and VGA ports, ensuring compatibility with laptops, desktops, gaming consoles, and other devices commonly used by students and professionals.

The monitor is in good working condition with no dead pixels, scratches, or display issues. The screen surface is clean, and all ports and buttons are fully functional. The stand is stable and allows for comfortable viewing angles. This makes it an ideal choice for setting up a productive workspace in hostel rooms, dormitories, or home offices.

Energy-efficient design ensures lower power consumption, which is beneficial for students managing electricity costs. The compact size makes it suitable for limited desk space while still providing ample screen real estate for multitasking and productivity. Perfect for students, remote workers, freelancers, and anyone seeking a reliable display solution at an affordable price point.""",

        'bicycle': f"""This {object_name} is a well-maintained two-wheeler that has served its previous owner reliably. The bicycle is in excellent working condition with all components functioning properly. The frame is sturdy and shows minimal wear, indicating careful usage and regular maintenance.

The bike features smooth gear shifting, responsive brakes, and properly inflated tires with good tread depth. The chain is well-lubricated and the pedals rotate smoothly without any unusual sounds or resistance. All safety features including reflectors and bell are intact and functional.

This bicycle is perfect for campus commuting, daily exercise, short-distance travel, and eco-friendly transportation. It offers an excellent alternative to motorized vehicles, helping reduce carbon footprint while providing health benefits through physical activity. The bike is lightweight enough for easy maneuvering yet durable enough to handle regular use on various terrains.

Ideal for students who need reliable transportation between classes, hostel, and nearby locations. Also suitable for fitness enthusiasts looking for an affordable way to incorporate exercise into their daily routine. The bicycle comes with basic maintenance, and the new owner can expect many more years of reliable service with proper care.""",

        'mattress': f"""This {object_name} is a quality sleeping surface that has been well-cared for and maintained in hygienic condition. The mattress provides proper support and comfort, essential for quality rest and recovery. It features good firmness that supports the spine while allowing comfortable sleep throughout the night.

The mattress surface is clean with no stains, odors, or damage. The material is in good condition with proper padding and support layers intact. It maintains its shape well and doesn't show signs of sagging or deformation. The edges are firm, and the overall structure is solid.

Perfect for hostel rooms, dormitories, student accommodations, or any compact living space requiring a single bed mattress. The size is appropriate for standard single bed frames commonly found in student housing. The mattress offers excellent value for money, providing quality sleep at a fraction of the cost of a new mattress.

Ideal for students, young professionals, or anyone setting up their first independent living space. The mattress has been used carefully, and with proper care including regular rotation and cleaning, it will continue to provide comfortable sleep for years to come. A great investment for anyone prioritizing both budget and quality rest.""",

        'chair': f"""This {object_name} is a comfortable and functional seating solution that has been well-maintained throughout its use. The chair features ergonomic design elements that provide proper back support, making it ideal for extended study sessions, work-from-home setups, and academic activities.

The seat padding is in good condition with no significant wear or damage. The backrest offers adequate support for maintaining proper posture during long hours of sitting. The armrests, if present, are stable and at comfortable height. The chair's height is adjustable, allowing users to find their optimal seating position.

The base is stable with all legs intact and properly balanced. The wheels, if applicable, roll smoothly without sticking or making noise. The overall construction is solid, indicating quality materials and good craftsmanship. The upholstery is clean with no major stains or tears.

Perfect for students setting up study spaces in hostel rooms, remote workers creating home offices, or anyone seeking comfortable seating for desk work. The chair's compact design makes it suitable for limited spaces while still providing comfort and functionality. An excellent choice for anyone spending significant time at a desk, whether for academic work, professional tasks, or personal projects.""",

        'table': f"""This {object_name} is a sturdy and practical work surface that has been well-maintained and is in excellent condition. The table provides ample space for laptops, books, study materials, and other essentials needed for academic or professional work.

The surface is smooth and level, free from major scratches, stains, or damage. It's large enough to accommodate a laptop, monitor, books, notebooks, and other study materials simultaneously, making it perfect for multitasking and organized work. The edges are smooth and finished properly.

The legs are stable and properly balanced, ensuring the table doesn't wobble or shift during use. The construction is solid, indicating quality materials and good craftsmanship. The height is appropriate for standard chairs and provides comfortable working position for extended study or work sessions.

Ideal for hostel rooms, dormitories, study areas, or any compact living space requiring a functional workspace. The table's design is practical and space-efficient, making it perfect for students, remote workers, or anyone setting up a productive work environment on a budget.

Perfect for academic work, online classes, coding projects, design work, or any activity requiring a stable and spacious surface. The table has been used carefully and maintained well, ensuring many more years of reliable service for the new owner.""",

        'headphone': f"""This {object_name} is a quality audio device that delivers excellent sound performance for music, calls, online classes, and entertainment. The headphones have been well-maintained and are in good working condition with all features functioning properly.

The sound quality is clear with good bass response and balanced audio across different frequencies. The device provides immersive listening experience whether for music, podcasts, audiobooks, or multimedia content. The microphone, if present, picks up voice clearly, making it perfect for video calls, online classes, and gaming.

The ear cushions are in good condition with proper padding that provides comfort during extended use. The headband is adjustable and fits securely without causing discomfort. The build quality is solid, and the cables, if wired, are in good condition without frays or damage.

Perfect for students attending online classes, professionals working remotely, music enthusiasts, gamers, or anyone seeking quality audio experience. The headphones offer excellent noise isolation, allowing focused study or work in noisy environments like hostels or shared spaces.

Ideal for campus life where privacy and focus are important. The device is portable and easy to carry, making it convenient for use in libraries, study halls, or while commuting. A great investment for anyone prioritizing both audio quality and affordability.""",

        'phone': f"""This {object_name} is a modern smartphone that has been carefully used and well-maintained. The device is in good working condition with all essential features functioning properly. The screen is clear with no major scratches or cracks, and the display quality remains excellent.

The phone's performance is smooth with responsive touch interface and reliable operation of all apps and functions. The battery holds charge well and provides reasonable usage time for daily activities. The camera functions properly and captures good quality photos and videos for social media, documentation, and personal use.

All ports, buttons, and sensors are working correctly. The device connects reliably to Wi-Fi and cellular networks, ensuring consistent communication and internet access. The storage capacity is adequate for apps, photos, documents, and media files needed for student life and daily activities.

Perfect for students, young professionals, or anyone seeking a reliable smartphone at an affordable price. The phone handles everyday tasks including messaging, social media, online classes, navigation, and entertainment without issues. It's an excellent choice for those who need modern smartphone functionality without the premium price tag.

The device has been used carefully with protective measures, and the new owner can expect continued reliable performance. Ideal for campus life, remote work, or personal use where connectivity and functionality are essential.""",

        'cooler': f"""This {object_name} is an efficient air cooling appliance that has been well-maintained and is in excellent working condition. The cooler provides effective cooling for small to medium-sized spaces, making it perfect for hostel rooms, dormitories, and compact living areas.

The cooling mechanism functions properly, delivering good airflow and temperature reduction. The water tank and pump system work correctly, ensuring consistent cooling performance. The fan operates smoothly at different speed settings, allowing users to adjust according to their comfort needs.

The appliance is energy-efficient, consuming less power compared to air conditioners, which is beneficial for students managing electricity costs. The design is compact and portable, making it easy to move and position as needed. The controls are intuitive and easy to operate.

Perfect for hot weather conditions, providing relief during summer months in non-air-conditioned spaces. The cooler is easy to maintain and clean, ensuring hygienic operation. It's an excellent solution for anyone seeking affordable climate control without the high cost and installation requirements of air conditioning systems.

Ideal for students, hostel residents, or anyone living in compact spaces where traditional cooling solutions are impractical or expensive. The appliance has been used carefully and maintained well, ensuring reliable performance for the new owner.""",

        'sneaker': f"""These {object_name} are quality athletic shoes that have been well-maintained and are in good condition. The footwear provides excellent comfort, support, and traction, making them perfect for various activities including sports, gym workouts, daily walking, and casual wear.

The shoes feature good cushioning that provides comfort during extended wear and impact absorption during physical activities. The sole has adequate tread depth, ensuring good grip on various surfaces. The upper material is in good condition with no major tears or significant wear.

The fit is comfortable with proper support for the feet, reducing fatigue during long walks or exercise sessions. The laces and fastening system are functional, allowing secure and adjustable fit. The overall construction is solid, indicating quality materials and good craftsmanship.

Perfect for fitness enthusiasts, athletes, students, or anyone leading an active lifestyle. The shoes are suitable for running, gym workouts, sports activities, or everyday casual wear. They offer excellent value for money, providing quality athletic footwear at an affordable price point.

Ideal for campus life where comfort and functionality are important. The shoes have been used carefully and maintained well, ensuring continued reliable performance. A great choice for anyone seeking durable and comfortable athletic footwear without the premium brand price tag.""",

        'backpack': f"""This {object_name} is a durable and spacious carrying bag that has been well-maintained and is in excellent condition. The bag features multiple compartments and pockets, providing organized storage for books, laptops, notebooks, water bottles, and other daily essentials.

The main compartment is roomy enough to accommodate textbooks, binders, and a laptop comfortably. Additional pockets allow for easy organization of smaller items like pens, chargers, keys, and personal belongings. The zippers are strong and function smoothly, ensuring secure closure of all compartments.

The shoulder straps are padded and adjustable, providing comfort during extended wear. The back panel is designed for breathability and comfort, reducing strain on the shoulders and back. The overall construction is sturdy, with reinforced stitching and quality materials that withstand daily use.

Perfect for students carrying books and laptops to classes, professionals commuting to work, travelers needing reliable luggage, or anyone seeking a practical and durable carrying solution. The bag's design balances functionality with style, making it suitable for various occasions and environments.

Ideal for campus life where reliable storage and easy transportation of essentials are crucial. The backpack has been used carefully and maintained well, ensuring many more years of reliable service. A great investment for anyone prioritizing both functionality and affordability.""",

        'bed': f"""This {object_name} is a sturdy and well-constructed sleeping furniture piece that has been carefully maintained and is in excellent condition. The bed frame provides solid support and stability, essential for quality rest and long-term durability.

The frame structure is solid with all joints and connections secure. The slats or support system are intact and properly positioned, ensuring even weight distribution and mattress support. The legs are stable and properly balanced, preventing wobbling or shifting during use.

The bed's design is practical and space-efficient, making it perfect for hostel rooms, dormitories, and compact living spaces. The height is appropriate, allowing for under-bed storage if needed. The overall construction quality is good, indicating durable materials and proper craftsmanship.

Perfect for students setting up their living space, young professionals furnishing their first apartment, or anyone seeking affordable and reliable sleeping furniture. The bed frame accommodates standard single-size mattresses commonly used in student housing and compact living arrangements.

Ideal for anyone prioritizing both budget and quality when furnishing their living space. The bed has been used carefully and maintained well, ensuring continued reliable service. A great choice for those seeking durable and functional furniture without the high cost of new items."""
    }
    
    # Find matching description
    for key, desc in descriptions.items():
        if key in object_name.lower():
            return desc
    
    # Generic description for unknown objects
    return f"""This {object_name.replace('_', ' ').title()} is a well-maintained item that has been carefully used and is in good working condition. The product offers practical functionality and reliable performance, making it suitable for various everyday applications.

The item has been maintained with regular care, ensuring it remains in excellent condition for continued use. All components and features are functional, and the overall quality is good. The design is practical and user-friendly, making it easy to operate and maintain.

Perfect for students, young professionals, or anyone seeking quality products at affordable prices. The item is suitable for campus life, hostel living, or everyday use in various settings. It offers excellent value for money, providing reliable functionality without the premium cost of new items.

The product has been used carefully by its previous owner, and with proper care and maintenance, it will continue to serve reliably for years to come. Ideal for anyone setting up their living space, starting their academic journey, or seeking practical solutions for everyday needs.

This item represents a smart investment for budget-conscious buyers who prioritize both quality and affordability. The condition is excellent, and the new owner can expect continued reliable performance and satisfaction with their purchase."""

def get_listing_data():
    """Fetch listing data with image URLs from database"""
    query = """
    SELECT l.listing_id, l.title, l.description, l.category, li.image_url
    FROM listings l
    JOIN listing_images li ON l.listing_id = li.listing_id
    ORDER BY l.listing_id
    """
    
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '-e', query,
        '-s',  # silent mode
        '-N'   # skip column names
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        lines = result.stdout.strip().split('\n')
        
        listings = []
        for line in lines:
            if not line.strip():
                continue
            parts = line.split('\t')
            if len(parts) >= 5:
                listings.append({
                    'listing_id': parts[0],
                    'old_title': parts[1],
                    'old_description': parts[2],
                    'category': parts[3],
                    'image_url': parts[4]
                })
        return listings
    except subprocess.CalledProcessError as e:
        print(f"Error querying database: {e.stderr}")
        sys.exit(1)

def extract_filename_from_url(image_url):
    """Extract filename from image URL"""
    return image_url.replace('/images/', '')

def update_listing(listing_id, new_title, new_description):
    """Update listing title and description in database"""
    # Escape single quotes
    new_title = new_title.replace("'", "''")
    new_description = new_description.replace("'", "''")
    
    query = f"UPDATE listings SET title = '{new_title}', description = '{new_description}' WHERE listing_id = '{listing_id}';"
    
    cmd = [
        'mysql',
        f'-h{DB_HOST}',
        f'-P{DB_PORT}',
        f'-u{DB_USER}',
        f'-p{DB_PASSWORD}',
        DB_NAME,
        '-e', query
    ]
    
    try:
        subprocess.run(cmd, capture_output=True, text=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error updating database: {e.stderr}")
        return False

def main():
    print("=" * 70)
    print("Updating Listing Titles and Descriptions Based on Images")
    print("=" * 70)
    print()
    
    print("Step 1: Fetching listing data from database...")
    listings = get_listing_data()
    print(f"Found {len(listings)} listings with images")
    print()
    
    print("Step 2: Processing listings and generating new content...")
    success_count = 0
    error_count = 0
    
    for i, listing in enumerate(listings, 1):
        listing_id = listing['listing_id']
        old_title = listing['old_title']
        old_description = listing['old_description']
        category = listing['category']
        image_url = listing['image_url']
        
        # Extract object name from filename
        filename = extract_filename_from_url(image_url)
        object_name = extract_object_from_filename(filename)
        
        # Generate new title and description
        new_title = generate_title(object_name, category, listing_id)
        new_description = generate_description(object_name, category, new_title)
        
        # Verify lengths
        if len(new_title) < 100:
            print(f"[{i}/{len(listings)}] ⚠️  Warning: Title too short ({len(new_title)} chars) for {listing_id}")
            # Extend title
            new_title = new_title + " - Excellent Quality Product in Great Condition Perfect for Students and Daily Use"
        
        if len(new_description) < 500:
            print(f"[{i}/{len(listings)}] ⚠️  Warning: Description too short ({len(new_description)} chars) for {listing_id}")
            # Extend description
            extension = " This item has been carefully maintained and is ready for immediate use. Perfect for anyone seeking quality products at affordable prices. The condition is excellent, and the new owner can expect reliable performance and satisfaction. Ideal for students, young professionals, or anyone setting up their living or workspace on a budget."
            new_description = new_description + extension
        
        # Update database
        if update_listing(listing_id, new_title, new_description):
            success_count += 1
            print(f"[{i}/{len(listings)}] ✅ Updated: {object_name} (Title: {len(new_title)} chars, Desc: {len(new_description)} chars)")
        else:
            error_count += 1
            print(f"[{i}/{len(listings)}] ❌ Error updating {listing_id}")
    
    print()
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print(f"✅ Successfully updated: {success_count}")
    print(f"❌ Errors: {error_count}")
    print(f"📊 Total processed: {len(listings)}")
    print()

if __name__ == "__main__":
    main()

