seller = User.create(email: "test@example.com", password: "password")
#Create products for the first seller account.
products = seller.products.create(
  [
    {
        title: "Email Newsletter Template",
        description: "<p>This <strong>email newsletter template</strong> is perfect for reaching your audience. Customize it with your branding and content to keep your subscribers engaged. With a modern design and responsive layout, it looks great on any device. Easily integrate your social media links and call-to-action buttons to drive more traffic to your website.</p>",
        price: 29
    },
    {
        title: "Ebook Template",
        description: "<p>Our <em>ebook template</em> offers a sleek and professional design to showcase your content. It's fully editable and compatible with various software, making it easy to adapt to your needs. The template includes multiple page layouts, customizable graphics, and a stylish cover page. Perfect for authors, marketers, and businesses looking to publish high-quality ebooks.</p>",
        price: 49
    },
    {
        title: "CV Resume Template",
        description: "<p>Stand out in your job search with this <strong>CV resume template</strong>. Designed to highlight your skills and experience effectively, this template features a clean and modern layout. It includes sections for your professional summary, work history, education, skills, and more. Easy to edit in popular software programs, this template helps you make a great first impression.</p>",
        price: 19
    },
    {
        title: "Flyer Template",
        description: "<p>Create stunning flyers with our <em>flyer template</em>. Ideal for promoting events, sales, or special announcements, this template is highly customizable. Choose from a variety of color schemes, fonts, and graphics to match your brand. Print-ready and easy to edit, this flyer template ensures your message stands out and grabs attention.</p>",
        price: 15
    },
    {
        title: "Presentation Template",
        description: "<p>This <strong>presentation template</strong> will help you deliver powerful presentations with ease. Professionally designed slides are ready to use and include various layout options for text, images, charts, and graphs. Enhance your presentations with visually appealing graphics and ensure your key points are communicated effectively. Perfect for business meetings, conferences, and educational purposes.</p>",
        price: 35
    }
  ]
)

#Attach product images from a local folder.
products.each do |product|
  Dir.children("db/images/#{product.title}").each do |filename|
    filename = Rails.root.join("db/images/#{product.title}/#{filename}")
    puts filename
    product.images.attach(io: File.open(filename), filename: filename)
  end
end


# Use the Faker gem to create new user accounts and products with images
require 'open-uri'

#Add missing name and profile photos for existing users.
User.find_each do |user|
  user.update(name: Faker::Name.name) if user.name.nil?
  if !user.profile_photo.attached?
    profile_photo = URI.open("https://robohash.org/#{user.name.gsub(' ', '')}")
    user.profile_photo.attach(io: profile_photo,
                            filename: "#{user.name}.jpg")
  end
end

#Create a new seller account with a profile photo
seller = User.create(
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: "password")

profile_photo = URI.open("https://robohash.org/#{seller.name.gsub(' ', '')}")
seller.profile_photo.attach(io: profile_photo,
                            filename: "#{seller.name}.jpg")

#Create new products for the seller
products = seller.products.create(
  6.times.map do
    {
      title: [Faker::Commerce.product_name, ["Template", "Wallpaper", "Kit"].sample].join(" "),
      description: Faker::Lorem.paragraphs(number: 4).join("<br/><br/>"),
      price: Faker::Commerce.price
    }
  end
)

#Attach product images from a Faker URL.
products.each do |product|
  3.times do |i|
    image = URI.open(Faker::LoremFlickr.image)
    product.images.attach(io: image, filename: "#{product.title}_#{i}.jpg")
  end
end
