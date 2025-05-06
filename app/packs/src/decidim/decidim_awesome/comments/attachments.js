const addResetCommentForm = (form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    Reflect.apply(Rails.handleRemote, event.target, [event]);
    event.target.reset();
  });
};

document.querySelectorAll(".comment__form-submit button[type='submit']").forEach((item) => addResetCommentForm(item.form));

document.addEventListener("comments:loaded", (event) => {
  const commentsIds = event.detail.commentsIds;
  if (commentsIds) {
    commentsIds.forEach((commentId) => {
      const commentsContainer = document.getElementById(`comment_${commentId}`);
      if (commentsContainer) {
        commentsContainer.querySelectorAll(".comment__form-submit button[type='submit']").forEach((item) => addResetCommentForm(item.form));
      }
    });
  }
});
