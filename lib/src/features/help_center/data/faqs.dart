import '../domain/entities/faq.dart';

final List<FaqSection> helpCenterFaqs = [
  FaqSection(
    title: 'Booking & Appointments',
    items: [
      FaqItem(
        question: 'How do I book a service on BookMySpa?',
        answer:
            'Open the app, select a category or spa, choose your preferred service and time slot, and confirm the booking.',
      ),
      FaqItem(
        question: 'Can I reschedule my appointment?',
        answer:
            'Yes, appointments can be rescheduled from the My Bookings section, subject to spa availability.',
      ),
      FaqItem(
        question: 'What happens if the spa cancels my booking?',
        answer:
            'You will be notified and any paid amount will be refunded as per the refund policy.',
      ),
      FaqItem(
        question: 'Where can I see my upcoming bookings?',
        answer:
            'All upcoming and past bookings are available in the My Bookings section.',
      ),
    ],
  ),
  FaqSection(
    title: 'Payments & Refunds',
    items: [
      FaqItem(
        question: 'What payment methods are supported?',
        answer:
            'UPI, debit cards, credit cards, and other available online payment options are supported.',
      ),
      FaqItem(
        question:
            'My payment failed, but money was deducted. What should I do?',
        answer:
            'If the amount is deducted but the booking is not confirmed, it will usually be refunded automatically within a few working days.',
      ),
      FaqItem(
        question: 'How long does it take to get a refund?',
        answer:
            'Refunds are generally processed within 5–7 business days, depending on the bank or payment method.',
      ),
    ],
  ),
  FaqSection(
    title: 'Cancellations & No-Show',
    items: [
      FaqItem(
        question: 'Can I cancel my booking?',
        answer:
            'Bookings can be cancelled from the My Bookings section, and applicable charges depend on the spa’s cancellation policy.',
      ),
      FaqItem(
        question: 'What is a no-show?',
        answer:
            'A no-show occurs when a user does not arrive for the appointment without cancelling, and refunds may not be applicable.',
      ),
    ],
  ),
  FaqSection(
    title: 'Offers, Coupons & Wallet',
    items: [
      FaqItem(
        question: 'How do I apply a coupon?',
        answer:
            'Coupons can be applied on the payment screen before confirming the booking.',
      ),
      FaqItem(
        question: 'Why is my coupon not working?',
        answer:
            'Coupons may have conditions such as minimum booking value, expiry date, or service restrictions.',
      ),
      FaqItem(
        question: 'How do I use wallet balance?',
        answer:
            'Available wallet balance is automatically applied during checkout.',
      ),
    ],
  ),
  FaqSection(
    title: 'Ratings & Reviews',
    items: [
      FaqItem(
        question: 'How can I write a review for a spa?',
        answer:
            'After completing a service, users can submit a rating and review from their booking history.',
      ),
      FaqItem(
        question: 'Can I like or dislike a review?',
        answer:
            'Users can like or dislike a review once and can change or revert their reaction, similar to YouTube comments.',
      ),
      FaqItem(
        question: 'Can I edit or delete my review?',
        answer:
            'Reviews cannot be edited or deleted once submitted.',
      ),
    ],
  ),
  FaqSection(
    title: 'Account & Profile',
    items: [
      FaqItem(
        question: 'How do I update my profile details?',
        answer:
            'Profile details can be updated from Profile → Edit Profile.',
      ),
      FaqItem(
        question: 'I’m not receiving OTP. What should I do?',
        answer:
            'Check network connectivity and phone number correctness, then retry after a few seconds.',
      ),
      FaqItem(
        question: 'How can I delete my account?',
        answer:
            'Account deletion can be requested through the Help Centre or by contacting support.',
      ),
    ],
  ),
  FaqSection(
    title: 'Safety, Hygiene & Verification',
    items: [
      FaqItem(
        question: 'Are spas on BookMySpa verified?',
        answer:
            'Yes, all spas are verified before being listed.',
      ),
      FaqItem(
        question: 'What if I face a hygiene or service issue?',
        answer:
            'Issues can be reported through the Help Centre or by contacting support.',
      ),
    ],
  ),
  FaqSection(
    title: 'Contact Support',
    items: [
      FaqItem(
        question: 'How can I contact BookMySpa support?',
        answer:
            'Support is available via WhatsApp(+917652067023), email(avrsoftdev@gmail.com), or the Help Centre section in the app.',
      ),
    ],
  ),
];
